import java.io.*;
import java.util.*;

public class TIADSplitter {

	public static void main(String[] argv) throws Exception {
		if(argv.length==0 || !argv[0].equals("-silent")) 
			System.err.println("synopsis: TIADSplitter [-silent]\n"+
			"\t-silent suppress this message\n"+
			"read TIAD/TSV files from stdin, retrieve language codes from cols 1 and 7 (numbering starts at 1), create files LANG1-LANG2.tsv for each pair\n"+
			"do not filter for duplicates, skip lines without language tags");
		
		Hashtable<String,Hashtable<String,Writer>> src2tgt2writer = new Hashtable<String,Hashtable<String,Writer>>();
		BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
		for(String line = in.readLine(); line!=null; line=in.readLine()) {
			String[] fields = line.split("\t");
			if(fields.length>7)
				if(fields[0].matches(".*@[a-z][a-z][a-z]?$"))
					if(fields[7].matches(".*@[a-z][a-z][a-z]?$")) {
						String s = fields[0].replaceAll(".*@","");
						String t = fields[7].replaceAll(".*@","");
						if(src2tgt2writer.get(s)==null)
							src2tgt2writer.put(s,new Hashtable<String,Writer>());
						if(src2tgt2writer.get(s).get(t)==null) {
							(new File(s)).mkdirs();
							File f = new File(new File(s),s+"-"+t+".tsv");							
							src2tgt2writer.get(s).put(t,new FileWriter(f));
						}
						src2tgt2writer.get(s).get(t).write(line+"\n");
						src2tgt2writer.get(s).get(t).flush();
					}
		}
		in.close();
		for(String s : src2tgt2writer.keySet())
			for(String t: src2tgt2writer.get(s).keySet())
				src2tgt2writer.get(s).get(t).close();
	}
}