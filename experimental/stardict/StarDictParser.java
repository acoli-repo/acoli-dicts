import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.RandomAccessFile;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.TreeSet;
import java.util.zip.GZIPInputStream;

import org.apache.commons.lang3.ArrayUtils;

/**
 * StarDict dictionary file parser
 * @author beethoven99@126.com
 * slightly modified by christian.chiarcos@web.de
 * 
 * CC: This implementation is based on https://github.com/wyage/star-dict-parser.
 * This seems to support pre-3.0.0 StarDict files only, but manages to work around a lot of offset issues my own implementation had.
 * For the format documentation, see https://code.google.com/archive/p/babiloo/wikis/StarDict_format.wiki
 * However, this is also much slower, because this is not a plain converter, but intended for search. 
 * It thus uses a RandomAccessFile rather than a straight-forward GZIPInputStream
 */
public class StarDictParser {

	/**
	 * plain pojo, define the position of a word
	 * @author beethoven99@126.com
	 */
	public class WordPosition {
		
		/**
		 * èµ·å§‹å­—èŠ‚ä½�ç½®
		 */
		private int startPos;
		
		/**
		 * å­—èŠ‚é•¿åº¦
		 */
		private int length;
		
		public WordPosition(int s,int l){
			this.startPos=s;
			this.length=l;
		}
		
		public int getStartPos() {
			return startPos;
		}
		public void setStartPos(int startPos) {
			this.startPos = startPos;
		}
		public int getLength() {
			return length;
		}
		public void setLength(int length) {
			this.length = length;
		}
		
	}


	/**
	 * byte[] functionality
	 * @author olaf@merkert.de, beethoven99@126.com 
	 */
	public static class ByteArrayHelper {
	
		public static long toLong(byte[] in) {
			long out = 0;
			for (int i = in.length - 1; i > 0; i--) {
				out |= in[i] & 0xff;
				out <<= 8;
			}
			out |= in[0] & 0xff;
			return out;
		}
	
		/**
		 * æŒ‰JAVAçš„å°�ç«¯é¡ºåº�æ�¥
		 * @param in
		 * @return
		 */
		public static int toInt(byte[] in) {
			int out = 0;
			for (int i = in.length - 1; i > 0; i--) {
				out |= in[i] & 0xff;
				out <<= 8;
			}
			out |= in[0] & 0xff;
			return out;
		}
	
		/**
		 * è½¬æˆ�intï¼ŒæŒ‰å¤§ç«¯åº�å�·æ�¥
		 * @param in
		 * @return
		 */
		public static int toIntAsBig(byte[] in) {
			int out = 0;
			for (int i = 0; i < in.length - 1; i++) {
				out |= in[i] & 0xff;
				out <<= 8;
			}
			out |= in[in.length - 1] & 0xff;
			return out;
		}
		
		/**
		 * è½¬æˆ�intï¼ŒæŒ‰å¤§ç«¯åº�å�·æ�¥
		 * @param in
		 * @return
		 */
		public static int toIntAsBig2(byte[] buf){
			int out=Integer.MAX_VALUE;
			out&=0x000000ff&buf[3];
			out|=0x0000ff00&(int)(buf[2])<<8;
			out|=0x00ff0000&(int)(buf[1])<<16;
			out|=0xff000000&(int)(buf[0])<<24;
			return out;
		}
		
		/**
		 * è½¬æˆ�intï¼ŒæŒ‰å¤§ç«¯åº�å�·æ�¥
		 * @param in
		 * @return
		 */
		public static int toIntAsBig3(byte[] buf){
			int out=0;
			out|=0x000000ff&buf[3];
			out|=0x0000ff00&(int)(buf[2])<<8;
			out|=0x00ff0000&(int)(buf[1])<<16;
			out|=0xff000000&(int)(buf[0])<<24;
			return out;
		}
	
		public static short toShort(byte[] in) {
			short out = 0;
			for (int i = in.length - 1; i > 0; i--) {
				out |= in[i] & 0xff;
				out <<= 8;
			}
			out |= in[0] & 0xff;
			return out;
		}
	
		public static byte[] toByteArray(int in) {
			byte[] out = new byte[4];
	
			out[0] = (byte) in;
			out[1] = (byte) (in >> 8);
			out[2] = (byte) (in >> 16);
			out[3] = (byte) (in >> 24);
	
			return out;
		}
	
		public static byte[] toByteArray(int in, int outSize) {
			byte[] out = new byte[outSize];
			byte[] intArray = toByteArray(in);
			for (int i = 0; i < intArray.length && i < outSize; i++) {
				out[i] = intArray[i];
			}
			return out;
		}
	
		public static String toString(byte[] theByteArray) {
			StringBuffer out = new StringBuffer();
			for (int i = 0; i < theByteArray.length; i++) {
				String s = Integer.toHexString(theByteArray[i] & 0xff);
				if (s.length() < 2) {
					out.append('0');
				}
				out.append(s).append(' ');
			}
			return out.toString();
		}
	
		public static boolean isEqual(byte[] first, byte[] second) {
			boolean out = first != null && second != null
					&& first.length == second.length;
			for (int i = 0; out && i < first.length; i++) {
				if (first[i] != second[i]) {
					out = false;
				}
			}
			return out;
		}
	
		public static int toInt(char[] cs) {
			return toInt(toByteArray(cs));
		}
	
		public static byte[] toByteArray(char[] cs) {
			byte[] res = new byte[cs.length];
			int i = 0;
			for (char c : cs) {
				res[i++] = (byte) c;
			}
			return res;
		}
	
		public static char[] toCharArray(byte[] cs) {
			char[] res = new char[cs.length];
			int i = 0;
			for (byte c : cs) {
				res[i++] = (char) c;
			}
			return res;
		}
	
		private static void testb() {
			byte[] bs = toByteArray(Integer.MAX_VALUE);
			for (byte b:bs) {
				System.out.print(b + ",");
			}
		}
		
		private static void testa() {
			try {
				FileOutputStream fos=new FileOutputStream("a.txt");
				fos.write(toByteArray(4577623),0, 4);
				fos.close();
				
				byte res[] = new byte[4];
				FileInputStream fis=new FileInputStream("a.txt");
				fis.read(res);
				fis.close();
				System.out.println(toInt(res));
				
			} catch (FileNotFoundException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
	
	
	
	private byte buf[]=new byte[1024];
	
	private int smark;
	
	private int mark;
	
	private Map<String,WordPosition> words=new HashMap<String,WordPosition>();

	public static final int MAX_RESULT=40;
	
	private RandomAccessFile randomAccessFile;
	
	/** substring search, not needed here */
	public List<Map.Entry<String,WordPosition>> searchWord(String term){
		List<Entry<String, WordPosition>> resa=new ArrayList<Map.Entry<String,WordPosition>>();
		List<Entry<String, WordPosition>> resb=new ArrayList<Map.Entry<String,WordPosition>>();
		
		int i=-1;
		for(Map.Entry<String, WordPosition> en:words.entrySet()){
			if(en.getKey()==null){
				System.err.println("oh no null");
			}
			i=en.getKey().toLowerCase().indexOf(term);
			if(i==0){
				resa.add(en);
			}else if(i>0 && resb.size()<MAX_RESULT){
				resb.add(en);
			}
			if(resa.size()>MAX_RESULT){
				break;
			}
		}
		
		Collections.sort(resa,WordComparator);
		Collections.sort(resb,WordComparator);
		
		if(resa.size()<MAX_RESULT){
			int need=MAX_RESULT-resa.size();
			if(need>resb.size()){
				need=resb.size();
			}
			resa.addAll(resb.subList(0, need));
		}
		return resa;
	}
	
	/**
	 * @param f
	 */
	public boolean loadContentFile(String f){
		try {
			this.randomAccessFile=new java.io.RandomAccessFile(f, "r");
			// System.err.println("is file open valid: "+this.randomAccessFile.getFD().valid());
		} catch (IOException e) {
			e.printStackTrace();
			return false;
		}
		return true;
	}
	
	/**
	 * @param start offset point
	 * @param len length to get
	 * @return
	 */
	public String getWordExplanation(int start,int len){
		String res="";
		try {
			if(len<=0) len=(int)Math.min(10, (int)(this.randomAccessFile.length()-(long)start));
			if(len<=0) return res;
			byte[] buf=new byte[len];
			this.randomAccessFile.seek(start);
			int ir=this.randomAccessFile.read(buf);
			if(ir!=len){
				System.err.println("Error occurred, not enought bytes read, wanting:"+len+",got:"+ir);
			}
			res=new String(buf,"utf-8");
		} catch (IOException e) {
			e.printStackTrace();
		}
		return res;
	}
	
	/**
	 * @param f
	 */
	public void loadIndexFile(String f){
		FileInputStream fis=null;
		try {
			fis=new FileInputStream(f);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
		
		try {
			//ç¬¬ä¸€æ¬¡è¯»
			int res=fis.read(buf);
			while(res>0){
				mark=0;
				smark=0;
				parseByteArray(buf,1024);
				if(mark==res){
					res=fis.read(buf);
				}else{
					res=fis.read(buf,buf.length-smark, smark);
				}
			}
		} catch (IOException e) {
			e.printStackTrace();
		}finally{
			try {
				fis.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		
		try {
			fis.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
	}
	
	/**
	 * parse a block of bytes
	 * @throws UnsupportedEncodingException
	 */
	private void parseByteArray(byte buf[],int len) throws UnsupportedEncodingException{
		for(;mark<len;){
			if(buf[mark]!=0){
				if(mark==len-1){
					System.arraycopy(buf, smark, buf, 0, len-smark);
					break;
				}else{
					mark++;
				}
			}else{
				String tword=null;
				if(mark!=0){
					byte[] bs=ArrayUtils.subarray(buf, smark, mark);
					tword=new String(bs,"utf-8");
				}
				
				if(len-mark>8){
					smark=mark+9;
					byte[] bstartpos = ArrayUtils.subarray(buf, mark+1,mark+5);
					byte[] blen=ArrayUtils.subarray(buf, mark+5, mark+9);
					int startpos=ByteArrayHelper.toIntAsBig(bstartpos);
					int strlen=ByteArrayHelper.toIntAsBig(blen);
					if(tword!=null && tword.trim().length()>0 && strlen<10000){
						words.put(tword, new WordPosition(startpos,strlen));
					}
					mark+=8;
				}else{
					System.arraycopy(buf, smark, buf, 0, len-smark);
					break;
				}
			}
		}
	}
	
	public Map<String, WordPosition> getWords() {
		return words;
	}
	
	public void setWords(Map<String, WordPosition> words) {
		this.words = words;
	}
	
	/**
	 * customer comparator
	 */
	private  static Comparator<Map.Entry<String,WordPosition>> WordComparator=new Comparator<Map.Entry<String,WordPosition>>(){
		public int compare(Map.Entry<String,WordPosition> ea,Map.Entry<String,WordPosition> eb){
			return ea.getKey().compareToIgnoreCase(eb.getKey());
		}
	};
	
	public static void main(String[] argv) throws Exception {
		if(argv.length<=2 || !argv[2].equalsIgnoreCase("-silent")) {
			System.err.println("synopsis: StarDictParser DIC IDX [-silent]\n"+
				"\tDIC dictionary file, ending in .dz, .dict, or .dic\n"+
				"\t    if ending in .dz, we expect gzipped content\n"+
				"\tIDX index file, normally ending in .idx\n"+
				"\t-silent skip all messages\n"+
				"writes the dictionary in a simple TSV representation to stdout:\n"+
				"WORD<TAB>ARTICLE_H\n"+
				"WORD is trimmed, ARTICLE_H is trimmed, with line breaks preserved as HTML markup.\n"+
				"If ARTICLE(_H) starts with WORD, WORD and optional punctuation marks are skipped.");
		}
		
		String dz=argv[0]; 
		String idx=argv[1]; 
				
		StarDictParser rdw=new StarDictParser();
		rdw.loadIndexFile(idx);
		System.err.print("processing "+dz+" .");
		if(dz.endsWith(".dz")) {
			// System.err.println("gunzip "+dz);
			System.err.print(".");
			File dz2 = File.createTempFile(dz, ".gunzipped");
			dz2.deleteOnExit();
			FileOutputStream out = new FileOutputStream(dz2);
			InputStream in = new GZIPInputStream(new FileInputStream(dz));
			for(int c = in.read(); c!=-1; c=in.read())
				out.write(c);
			in.close();
			out.close();
			dz=dz2.toString();
		}
		// System.err.println("load "+dz);
		System.err.print(".");
		rdw.loadContentFile(dz);
		// rdw.showWords();
		// rdw.testByConsole(); // finish with empty line
		// System.err.println("export");
		System.err.print(".");
		// for(String w : new TreeSet<String>(rdw.getWords().keySet())) {
		for(String w : rdw.getWords().keySet()) {
			String article = rdw.getWordExplanation(rdw.getWords().get(w).getStartPos(),rdw.getWords().get(w).getLength());
			if(article.startsWith(w)) article=article.substring(w.length()).replaceFirst("^[,:;\\.] ","");
			w=w.replaceAll("\\s+", " ").trim();
			article=article.trim().replaceAll("&","&amp;").replaceAll("<", "&lt;").replaceAll("\n", "<br/>").replaceAll("\\s+", " ").trim();
			System.out.println(w+"\t"+article);
		}
		rdw.close();
		System.err.println(". ok");
		
	}
	
	public void close() throws IOException {
		randomAccessFile.close();
	}
	
	/**
	 * test only
	 */
	public void testByConsole(){
		java.io.BufferedReader br=new java.io.BufferedReader(new java.io.InputStreamReader(System.in));
		String s=null;
		
		try {
			s=br.readLine();
			while(s.length()>0){
				System.out.println(s);
				List<Map.Entry<String,WordPosition>> res=this.searchWord(s);
				int i=0;
				for(Map.Entry<String,WordPosition> en:res){
					System.out.println(i+++" : "+en.getKey());
				}
				s=br.readLine();
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * debug
	 * 	 */
	public void showWords(){
		int i=0;
		for(Map.Entry<String, WordPosition> en:words.entrySet()){
			System.err.println(en.getKey()+" :"+en.getValue().getStartPos()+" - "+en.getValue().getLength());
			if(i++%25==0){
				System.err.println(this.getWordExplanation(en.getValue().getStartPos(), en.getValue().getLength()));
			}
		}
	}
}
