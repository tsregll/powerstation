package com.cw.plm.updatertu;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.RandomAccessFile;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;
import org.springframework.util.StringUtils;

import com.cw.plm.bpserver.FillLeakEventHandler;
import com.hzjbbis.db.batch.AsyncService;
import com.hzjbbis.fk.clientmod.ClientModule;
import com.hzjbbis.fk.common.spi.abstra.BaseModule;
import com.hzjbbis.fk.message.gw.MessageGw;
import com.hzjbbis.fk.message.gw.MessageGwCreator;
import com.hzjbbis.fk.message.zj.MessageZj;
import com.hzjbbis.fk.utils.HexDump;

/**
 * 监控终端升级文件. monite RTU update files.
 * @author Administrator
 *
 */
public class UpdateRtuModule extends BaseModule {
	//static member
	private static final Logger log = Logger.getLogger(UpdateRtuModule.class);
	private static final UpdateRtuModule instance = new UpdateRtuModule();
	//configurable attributes
	private String updateFile = "update.txt";
	private String rtuaListFile = "rtua-list.";	//格式 rtua-list.{批次号}[.yyyyMMdd]
	private String monitePath = "data";
	private int packetLength = 500;
	//If it is updating RTU module, following attrs must set. 
	private String hostIp = null;
	private int hostPort = 10002;
	private FillLeakEventHandler eventHandler = null;		//must be BpServerEventHandler
	private int updateTimeout = 120;						//分钟
	private int resendInterval = 15;					//重发间隔(秒)
	private AsyncService dbService = null;
	private int daoKey = 1;
	//initialize load data DAO
	private LoadUpdatingRtuDao loadDao = null;
	
	//private attributes
	private FileMonitorThread thread = null;
	private ClientModule feClient = null;
	private Map<Integer,RtuStatus> updatingRtus = Collections.synchronizedMap(new HashMap<Integer,RtuStatus>());
	private List<RtuStatus> downQueue = new LinkedList<RtuStatus>();	//下行终端队列
	
	private UpdateRtuModule(){
		
	}
	
	public static final UpdateRtuModule getInstance(){
		return instance;
	}
	
	/**
	 * According update content and RTUA list ,generate packet and send to RTU
	 * @param update
	 * @param list
	 */
	private void handleUpdate(ByteBuffer content,List<String> list , String batchId){
		for(String s: list ){
			try{
				int rtua = (int)Long.parseLong(s, 16);
				RtuStatus rtu = new RtuStatus(batchId,rtua,content);
				updatingRtus.put(rtua, rtu);
				synchronized(downQueue){
					downQueue.add(rtu);
				}
			}catch(Exception e){
				log.warn("RTUA解析异常,string="+s+e.getLocalizedMessage());
			}
		}
		while( downQueue.size()>0 ){
			RtuStatus rtu = null;
			synchronized(downQueue){
				rtu = downQueue.remove(0);
			}
			MessageGw msg = rtu.nextPacket();
			if( !eventHandler.sendMessage(msg) ){
				synchronized(downQueue){
					downQueue.add(rtu);
				}
				break;
			}
		}
	}
	
	public void precessReplyMessage(MessageGw msg){
		//如果所有终端都升级完成，那么需要在升级目录下生成文件"updateCompleted.txt"
		ByteBuffer data = msg.data;
		if( data.remaining()<8 ){
			log.error("RTUA="+HexDump.toHex(msg.getRtua())+",FILE应答数据区长度<8，不符合规约.");
			updatingRtus.remove(msg.getRtua());
			return;
		}
		int ipacket = data.get(4) & 0x00FF;
		ipacket |= (data.get(5) & 0x00FF) << 8 ;
		ipacket |= (data.get(6) & 0x00FF) << 16 ;
		ipacket |= (data.get(7) & 0x00FF) << 24 ;
		RtuStatus rtu = updatingRtus.get(msg.getRtua());
		if( null == rtu ){
			log.error("receive rtu updating reply but not find RTU Object");
			return;
		}
		rtu.setLastTime(System.currentTimeMillis());
		if( ipacket == 0xFFFFFFFF ){
			//终端升级失败。
			updatingRtus.remove(rtu.getRtua());
			dbService.addToDao(new PojoUpdateState(rtu.getRtua(),rtu.getBatchId(),false,rtu.getTotalPacket(),rtu.getCurPacket()+1), daoKey);
		}
		if( rtu.isLastPacket() ){
			//终端升级完成。
			updatingRtus.remove(rtu.getRtua());
			dbService.addToDao(new PojoUpdateState(rtu.getRtua(),rtu.getBatchId(),true,rtu.getTotalPacket(),rtu.getCurPacket()+1), daoKey);
		}
		else{
			rtu.setCurPacket(ipacket);
			rtu.move();
			MessageGw nextmsg = rtu.nextPacket();
			if( !eventHandler.sendMessage(nextmsg) ){
				synchronized(downQueue){
					downQueue.add(rtu);
				}
			}
		}
		if( updatingRtus.size() == 0 )	//全部升级完成,目录下设置complete.txt
			setCompleteFile();
	}
	
	public void precessReplyMessage(MessageZj msg){
		
	}
	
	//定时更新升级工况。检查updatingRtus超过updateTimeout分钟没有应答的终端
	private void updateRtuStatus(){
		if( updatingRtus.size() == 0 )
			return;
		//待升级终端的超时检测。重发机制的实现。
		long timeout = updateTimeout * 60 * 1000;
		long now = System.currentTimeMillis();
		RtuStatus[] rtus = updatingRtus.values().toArray(new RtuStatus[0]);
		for(RtuStatus rtu: rtus ){
			long dif = now - rtu.getLastTime();
			if( dif > timeout ){
				//update timeout.升级超时，更新数据库升级失败
				synchronized(downQueue){
					downQueue.remove(rtu);
				}
				updatingRtus.remove(rtu.getRtua());
				dbService.addToDao(new PojoUpdateState(rtu.getRtua(),rtu.getBatchId(),false,rtu.getTotalPacket(),rtu.getCurPacket()+1), daoKey);
				log.warn("RTU update failed in sake of timeout. RTUA="+HexDump.toHex(rtu.getRtua()));
				continue;
			}
			dbService.addToDao(new PojoUpdateState(rtu.getRtua(),rtu.getBatchId(),rtu.getTotalPacket(),rtu.getCurPacket()+1), daoKey);
			//reSend mechanism 重发机制
			int cnt = rtu.getResendCount()+1;		//初始化是0
			if( cnt > 10 )
				cnt = 10;
			if( dif > this.resendInterval * 1000 * cnt ){
				//1 minute without receive reply,then resend it.
				rtu.incResendCount();
				synchronized(downQueue){
					if( !downQueue.contains(rtu) )
						downQueue.add(rtu);
				}
			}
		}
		//待发队列继续发送
		while( downQueue.size()>0 ){
			RtuStatus rtu = null;
			synchronized(downQueue){
				rtu = downQueue.remove(0);
			}
			MessageGw msg = rtu.nextPacket();
			if( !eventHandler.sendMessage(msg) ){
				synchronized(downQueue){
					downQueue.add(rtu);
				}
				break;
			}
		}
	}
	
	@Override
	public boolean start() {
		if( StringUtils.hasLength( monitePath) ){
			if(  !(monitePath.startsWith("/") || monitePath.indexOf(":\\")>0 ) ){
				monitePath = System.getProperty("user.dir") + File.separator + monitePath ;
			}
		}
		System.out.println("monite RTU update-file at:"+monitePath);
		if( null != hostIp ){
			//log.error("down Channel(BP) is not set.");
			if( null == feClient ){
				feClient = new ClientModule();
				feClient.setName("FeClient");
				feClient.setBufLength(1024*64);
				feClient.setHostIp(hostIp);
				feClient.setHostPort(hostPort);
				feClient.setHeartInterval(0);		//cancel heart beat
				feClient.setEventHandler(eventHandler);
				feClient.setMessageCreator(new MessageGwCreator());
				eventHandler.start();
				feClient.start();
			}
		}
		if( null != thread )
			thread.stopIt();
		thread = new FileMonitorThread();
		//load uncompleted updat
		if( null != loadDao ){
			List<RtuStatus> list = loadDao.load();
			log.info("Initialize load RTU count="+list.size());
			for(RtuStatus rtu: list){
				updatingRtus.put(rtu.getRtua(), rtu);
				synchronized(downQueue){
					downQueue.add(rtu);
				}
			}
			while( downQueue.size()>0 ){
				RtuStatus rtu = null;
				synchronized(downQueue){
					rtu = downQueue.remove(0);
				}
				MessageGw msg = rtu.nextPacket();
				if( !eventHandler.sendMessage(msg) ){
					synchronized(downQueue){
						downQueue.add(rtu);
					}
					break;
				}
			}
		}
		log.info("RTU update module is started successfully.");
		return true;
	}

	@Override
	public void stop() {
		if( null != thread )
			thread.stopIt();
		thread = null;
		if( null != feClient ){
			feClient.stop();
			feClient = null;
			eventHandler.stop();
		}
	}

	public String getModuleType() {
		return UpdateRtuModule.class.getName();
	}


	public void setUpdateFile(String updateFile) {
		this.updateFile = updateFile;
	}

	public void setRtuaListFile(String rtuaListFile) {
		this.rtuaListFile = rtuaListFile;
	}

	public void setMonitePath(String monitePath) {
		this.monitePath = StringUtils.trimWhitespace(monitePath);
	}

	public void setHostIp(String host) {
		this.hostIp = host;
	}

	public void setHostPort(int port) {
		this.hostPort = port;
	}

	public void setEventHandler(FillLeakEventHandler eventHandler) {
		this.eventHandler = eventHandler;
	}

	public ByteBuffer getContent(String batchId){
		File f = new File(monitePath + File.separator + this.updateFile + "." + batchId);
		if( !f.exists() )
			return null;
		ByteBuffer content = null;
		try{
			RandomAccessFile raf = new RandomAccessFile(f,"r");
			int flen = (int)raf.length();
			if( flen<10 )
				return null;
			byte[] buf = new byte[flen];
			raf.read(buf);
			raf.close();
			raf = null;
			
			boolean isHex = true;
			StringBuilder sb = new StringBuilder();
			for( byte c: buf ){
				if( Character.isLetterOrDigit(c) ){
					sb.append((char)c);
					continue;
				}
				if( Character.isWhitespace(c)){
					continue;
				}
				isHex = false;
				break;
			}
			if( isHex ){
				content = HexDump.toByteBuffer(sb.toString());
			}
			else
				content = ByteBuffer.wrap(buf);
		}catch(Exception e){}
		return content;
	}
	
	public void setUpdatingFile(){
		File complete = new File(monitePath + File.separator + "complete.txt");
		File updating = new File(monitePath + File.separator + "updating.txt");
		if( complete.exists() )
			complete.renameTo(updating);
		else{
			try{
			updating.createNewFile();
			}catch(Exception exp){}
		}
	}

	public void setCompleteFile(){
		File complete = new File(monitePath + File.separator + "complete.txt");
		File updating = new File(monitePath + File.separator + "updating.txt");
		if( updating.exists() )
			updating.renameTo(complete);
		else{
			try{
				complete.createNewFile();
			}catch(Exception exp){}
		}
	}
	
	class FileMonitorThread extends Thread {
		private volatile boolean stopping = false;
		public FileMonitorThread(){
			super("UpdateFileMonitor");
			setDaemon(true);
			start();
		}
		
		public void stopIt(){
			stopping = true;
		}
		
		@Override
		public void run() {
			long checkPoint = System.currentTimeMillis();
			while( ! stopping ){
				try{
					Thread.sleep(10*1000);
					moniteFile();
					long now = System.currentTimeMillis();
					if( now-checkPoint > 1000 * 60 ){
						//每分钟更新终端升级工况，检查updatingRtus下超过30分钟没有响应的终端
						checkPoint = now;
						updateRtuStatus();
					}
				}catch(Exception e){
					log.error("monite file error: "+e.getLocalizedMessage(),e);
				}
			}
		}
		
		private void moniteFile() throws Exception{
			ByteBuffer content = null;
			List<String> rtuaList = new ArrayList<String>();
			String batchId = null;

			File baseDir = new File(monitePath);
			File[] allFile = baseDir.listFiles();
			File fupdate = null, frtua = null;
			for(File f: allFile){
				if( ! f.isFile() )
					continue;
				if( f.getName().equalsIgnoreCase(updateFile) ){
					RandomAccessFile raf = new RandomAccessFile(f,"r");
					int flen = (int)raf.length();
					if( flen<10 )
						continue;
					byte[] buf = new byte[flen];
					raf.read(buf);
					raf.close();
					raf = null;
					
					boolean isHex = true;
					StringBuilder sb = new StringBuilder();
					for( byte c: buf ){
						if( Character.isLetterOrDigit(c) ){
							sb.append((char)c);
							continue;
						}
						if( Character.isWhitespace(c)){
							continue;
						}
						isHex = false;
						break;
					}
					if( isHex ){
						content = HexDump.toByteBuffer(sb.toString());
					}
					else
						content = ByteBuffer.wrap(buf);
					fupdate = f;
				}
				else if( f.getName().startsWith(rtuaListFile) ){
					String fname = f.getName();
					int index1 = fname.indexOf('.');
					if( index1<0 )
						continue;
					index1++;
					int index2 = fname.indexOf('.', index1);
					if( index2>0 )
						continue;
					batchId = fname.substring(index1);
					BufferedReader reader = new BufferedReader(new FileReader(f));
					String line;
					while( null != (line = reader.readLine()) ){
						if( StringUtils.hasText(line))
							rtuaList.add(line);
					}
					reader.close();
					frtua = f;
				}
			}
			if( fupdate != null && frtua != null ){
				fupdate.renameTo(new File(fupdate.getAbsolutePath()+"."+ batchId));
				handleUpdate(content,rtuaList,batchId);
				setUpdatingFile();
			}
		}
		
	}

	public void setPacketLength(int packetLength) {
		this.packetLength = packetLength;
	}

	public int getPacketLength() {
		return packetLength;
	}

	public void setUpdateTimeout(int updateTimeout) {
		if( updateTimeout <=10 )
			updateTimeout = 120;
		this.updateTimeout = updateTimeout;
	}

	public void setDbService(AsyncService dbService) {
		this.dbService = dbService;
	}

	public void setDaoKey(int daoKey) {
		this.daoKey = daoKey;
	}

	public void setResendInterval(int resendInterval) {
		this.resendInterval = resendInterval;
	}

	public void setLoadDao(LoadUpdatingRtuDao loadDao) {
		this.loadDao = loadDao;
	}
}
