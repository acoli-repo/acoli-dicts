import java.io.*;
import java.util.*;

/** todo: separate class and property */
public class PanLex {

	/** estimate for the relative amount of available memory, for splitting tables into chunks 
	 * note: you should set -Xmx such that you stay within physical RAM */
	static double allocatedMemory() {
		long allocatedMemory      = Runtime.getRuntime().totalMemory()-Runtime.getRuntime().freeMemory();
		return ((double)allocatedMemory)/(double)Runtime.getRuntime().maxMemory();
	}	

	/** return all files under the directory f that end with the pattern, regular files only */
	static List<File> getFiles(File f, String pattern) {
		List<File> result = new ArrayList<File>();
		if(f.isDirectory())
			for(File e : f.listFiles()) 
				result.addAll(getFiles(e,pattern));
		else
			if(f.getName().endsWith(pattern))
				result.add(f);
		return result;			
	}

	static void addLangvar(File dir, String srcPattern, String tgtPattern, BufferedReader langvar) throws IOException {
		
		List<File> sources = getFiles(dir, srcPattern);
		
		if(getFiles(dir,tgtPattern).size()==sources.size()) {
			System.err.println("addLangvar("+dir+", "+srcPattern+", "+tgtPattern+", Reader): all source files already converted, skipping");
		} else {
			long nr=0;
			System.err.print("read langvar.csv ..");

			Hashtable<Integer,String> id2lang_code = new Hashtable<Integer,String>();

			String line = null;
			boolean readAll = false;
			try {
				line = langvar.readLine();
			} catch (IOException e) {
				readAll=true;
			}

			while(line!=null && allocatedMemory()<0.8) {
				//System.err.print("\r"+(Runtime.getRuntime().totalMemory()-Runtime.getRuntime().freeMemory()) + " ("+allocatedMemory()+")    ");
				
				String[] fields = split(line);
				try {
					
					// id,lang_code,var_code,mutable,name_expr,script_expr,meaning,region_expr,uid_expr,grp
					int id = Integer.parseInt(fields[0]);
					id2lang_code.put(id,fields[1]);
					
					nr=nr+1;
					if(nr % 131 == 0)
						System.err.print("\rread langvar.csv  ... "+nr);
				} catch (Exception e) {
					e.printStackTrace();
					System.err.println("while processing \""+line+"\"");
				}
				line=langvar.readLine();
				if(line==null) readAll=true;
			}
			if(nr>0)
				System.err.println("\rread langvar.csv  ... "+nr);
			
			String outPattern = srcPattern+".tmp";
			if(readAll==true)
				outPattern=tgtPattern;
			
			nr=0;
			for(File f : sources) {
				BufferedReader in = new BufferedReader(new FileReader(f));
				File tgt = new File(f.getParentFile(), f.getName().replaceFirst(srcPattern,outPattern));
				if(tgt.exists()) {
					System.err.println("found "+tgt+", skipping");
				} else {
					System.err.print("\rwrite "+tgt+" ... "+nr+"          ");
					FileWriter out = new FileWriter(tgt);			
					for(line = in.readLine(); line!=null; line=in.readLine()) {
						out.write(line+"\n");
						if(line.contains("<langvar id=")) {
							int id = Integer.parseInt(line.replaceFirst(".*id=\"([^\"]*)\".*","$1"));
							if(id2lang_code.get(id)!=null)
								out.write("<lang_code>"+id2lang_code.get(id)+"</lang_code>\n");
						}
					}
					System.err.print("\rwrite "+tgt+" ... "+nr+"          ");
					out.flush();
					out.close();
					in.close();
				}
			}
			System.err.println();
			id2lang_code.clear();
			System.gc();
			if(!readAll) {
				addLangvar(dir, outPattern, tgtPattern, langvar);
				for(File tmp : getFiles(dir, outPattern)) 
					tmp.deleteOnExit();
			}
		}
	}
	
	static void addSourceLangvar(File dir, String srcPattern, String tgtPattern, BufferedReader source_langvar) throws IOException {
		
		List<File> sources = getFiles(dir, srcPattern);
		
		if(getFiles(dir,tgtPattern).size()==sources.size()) {
			System.err.println("addSourceLangvar("+dir+", "+srcPattern+", "+tgtPattern+", Reader): all source files already converted, skipping");
		} else {
			long nr=0;
			System.err.print("read source_langvar.csv ..");

			Hashtable<Integer,Vector<Integer>> source2langvar = new Hashtable<Integer,Vector<Integer>>();

			String line = null;
			boolean readAll = false;
			try {
				line = source_langvar.readLine();
			} catch (IOException e) {
				readAll=true;
			}

			while(line!=null && allocatedMemory()<0.8) {
				//System.err.print("\r"+(Runtime.getRuntime().totalMemory()-Runtime.getRuntime().freeMemory()) + " ("+allocatedMemory()+")    ");
				
				String[] fields = split(line);
				try {
					
					// id,source_langvar,var_code,mutable,name_expr,script_expr,meaning,region_expr,uid_expr,grp
					int source = Integer.parseInt(fields[0]);
					int langvar = Integer.parseInt(fields[1]);
					if(source2langvar.get(source)==null)
						source2langvar.put(source,new Vector<Integer>());
					source2langvar.get(source).add(langvar);
					
					nr=nr+1;
					if(nr % 131 == 0)
						System.err.print("\rread source_langvar.csv  ... "+nr);
				} catch (Exception e) {
					e.printStackTrace();
					System.err.println("while processing \""+line+"\"");
				}
				line=source_langvar.readLine();
				if(line==null) readAll=true;
			}
			if(nr>0)
				System.err.println("\rread source_langvar.csv  ... "+nr);
			
			String outPattern = srcPattern+".tmp";
			if(readAll==true)
				outPattern=tgtPattern;
			
			nr=0;
			for(File f : sources) {
				BufferedReader in = new BufferedReader(new FileReader(f));
				File tgt = new File(f.getParentFile(), f.getName().replaceFirst(srcPattern,outPattern));
				if(tgt.exists()) {
					System.err.println("found "+tgt+", skipping");
				} else {
					System.err.print("\rwrite "+tgt+" ... "+nr+"          ");
					FileWriter out = new FileWriter(tgt);			
					for(line = in.readLine(); line!=null; line=in.readLine()) {
						out.write(line+"\n");
						if(line.contains("<source id=")) {
							int id = Integer.parseInt(line.replaceFirst(".*id=\"([^\"]*)\".*","$1"));
							if(source2langvar.get(id)!=null)
								for(Integer l : source2langvar.get(id))
									out.write("<langvar id=\""+l+"\">\n"+
											"</langvar>\n");
						}
					}
					System.err.print("\rwrite "+tgt+" ... "+nr+"          ");
					out.flush();
					out.close();
					in.close();
				}
			}
			System.err.println();
			source2langvar.clear();
			System.gc();
			if(!readAll) {
				addSourceLangvar(dir, outPattern, tgtPattern, source_langvar);
				for(File tmp : getFiles(dir, outPattern)) 
					tmp.deleteOnExit();
			}
		}
	}
	
	static void addFormat(File dir, String srcPattern, String tgtPattern, BufferedReader format) throws IOException {
		
		List<File> sources = getFiles(dir, srcPattern);
		
		if(getFiles(dir,tgtPattern).size()==sources.size()) {
			System.err.println("addFormat("+dir+", "+srcPattern+", "+tgtPattern+", Reader): all source files already converted, skipping");
		} else {
			long nr=0;
			System.err.print("read format.csv ..");

			Hashtable<Integer,String> id2format = new Hashtable<Integer,String>();

			String line = null;
			boolean readAll = false;
			try {
				line = format.readLine();
			} catch (IOException e) {
				readAll=true;
			}

			while(line!=null && allocatedMemory()<0.8) {
				//System.err.print("\r"+(Runtime.getRuntime().totalMemory()-Runtime.getRuntime().freeMemory()) + " ("+allocatedMemory()+")    ");
				
				String[] fields = split(line);
				try {
					
					// id,format,var_code,mutable,name_expr,script_expr,meaning,region_expr,uid_expr,grp
					int id = Integer.parseInt(fields[0]);
					id2format.put(id,fields[1]);
					
					nr=nr+1;
					if(nr % 131 == 0)
						System.err.print("\rread format.csv  ... "+nr);
				} catch (Exception e) {
					e.printStackTrace();
					System.err.println("while processing \""+line+"\"");
				}
				line=format.readLine();
				if(line==null) readAll=true;
			}
			if(nr>0)
				System.err.println("\rread format.csv  ... "+nr);
			
			String outPattern = srcPattern+".tmp";
			if(readAll==true)
				outPattern=tgtPattern;
			
			nr=0;
			for(File f : sources) {
				BufferedReader in = new BufferedReader(new FileReader(f));
				File tgt = new File(f.getParentFile(), f.getName().replaceFirst(srcPattern,outPattern));
				if(tgt.exists()) {
					System.err.println("found "+tgt+", skipping");
				} else {
					System.err.print("\rwrite "+tgt+" ... "+nr+"          ");
					FileWriter out = new FileWriter(tgt);			
					for(line = in.readLine(); line!=null; line=in.readLine()) {
						out.write(line+"\n");
						if(line.contains("<format id=")) {
							int id = Integer.parseInt(line.replaceFirst(".*id=\"([^\"]*)\".*","$1"));
							if(id2format.get(id)!=null)
								out.write("<label>"+id2format.get(id)+"</label>\n");
						}
					}
					System.err.print("\rwrite "+tgt+" ... "+nr+"          ");
					out.flush();
					out.close();
					in.close();
				}
			}
			System.err.println();
			id2format.clear();
			System.gc();
			if(!readAll) {
				addFormat(dir, outPattern, tgtPattern, format);
				for(File tmp : getFiles(dir, outPattern)) 
					tmp.deleteOnExit();
			}
		}
	}
	
	static void addSourceFormat(File dir, String srcPattern, String tgtPattern, BufferedReader source_format) throws IOException {
		
		List<File> sources = getFiles(dir, srcPattern);
		
		if(getFiles(dir,tgtPattern).size()==sources.size()) {
			System.err.println("addSourceFormat("+dir+", "+srcPattern+", "+tgtPattern+", Reader): all source files already converted, skipping");
		} else {
			long nr=0;
			System.err.print("read source_format.csv ..");

			Hashtable<Integer,Integer> id2source_format = new Hashtable<Integer,Integer>();

			String line = null;
			boolean readAll = false;
			try {
				line = source_format.readLine();
			} catch (IOException e) {
				readAll=true;
			}

			while(line!=null && allocatedMemory()<0.8) {
				//System.err.print("\r"+(Runtime.getRuntime().totalMemory()-Runtime.getRuntime().freeMemory()) + " ("+allocatedMemory()+")    ");
				
				String[] fields = split(line);
				try {
					
					// id,source_format,var_code,mutable,name_expr,script_expr,meaning,region_expr,uid_expr,grp
					int id = Integer.parseInt(fields[0]);
					id2source_format.put(id,Integer.parseInt(fields[1]));
					
					nr=nr+1;
					if(nr % 131 == 0)
						System.err.print("\rread source_format.csv  ... "+nr);
				} catch (Exception e) {
					e.printStackTrace();
					System.err.println("while processing \""+line+"\"");
				}
				line=source_format.readLine();
				if(line==null) readAll=true;
			}
			if(nr>0)
				System.err.println("\rread source_format.csv  ... "+nr);
			
			String outPattern = srcPattern+".tmp";
			if(readAll==true)
				outPattern=tgtPattern;
			
			nr=0;
			for(File f : sources) {
				BufferedReader in = new BufferedReader(new FileReader(f));
				File tgt = new File(f.getParentFile(), f.getName().replaceFirst(srcPattern,outPattern));
				if(tgt.exists()) {
					System.err.println("found "+tgt+", skipping");
				} else {
					System.err.print("\rwrite "+tgt+" ... "+nr+"          ");
					FileWriter out = new FileWriter(tgt);			
					for(line = in.readLine(); line!=null; line=in.readLine()) {
						out.write(line+"\n");
						if(line.contains("<source id=")) {
							int id = Integer.parseInt(line.replaceFirst(".*id=\"([^\"]*)\".*","$1"));
							if(id2source_format.get(id)!=null)
								out.write("<format id=\""+id2source_format.get(id)+"\">\n"+
										"</format>\n");
						}
					}
					System.err.print("\rwrite "+tgt+" ... "+nr+"          ");
					out.flush();
					out.close();
					in.close();
				}
			}
			System.err.println();
			id2source_format.clear();
			System.gc();
			if(!readAll) {
				addSourceFormat(dir, outPattern, tgtPattern, source_format);
				for(File tmp : getFiles(dir, outPattern)) 
					tmp.deleteOnExit();
			}
		}
	}
	
	static void addExpr(File dir, String srcPattern, String tgtPattern, BufferedReader expr) throws IOException {

		List<File> sources = getFiles(dir, srcPattern);
		if(getFiles(dir,tgtPattern).size()==sources.size()) {
			System.err.println("addExpr("+dir+", "+srcPattern+", "+tgtPattern+", Reader): all source files already converted, skipping");
		} else {
		
			long nr=0;
			System.err.print("read expr.csv ..");
			Hashtable<Integer,Hashtable<Integer,String>> expr2langvar2txt = new Hashtable<Integer,Hashtable<Integer,String>>();
			
			String line = null;
			boolean readAll = false;
			try {
				line = expr.readLine();
			} catch (IOException e) {
				readAll=true;
			}

			while(line!=null && allocatedMemory()<0.8) {
				
				String[] fields = split(line);
				try {
					int e = Integer.parseInt(fields[0]);
					int langvar = Integer.parseInt(fields[1]);
					String txt = ""; 
					if(fields.length>2) txt=fields[2]; // fields[3]: normalized txt
					if(expr2langvar2txt.get(e)==null)
						expr2langvar2txt.put(e,new Hashtable<Integer,String>());
					expr2langvar2txt.get(e).put(langvar,txt);
					nr=nr+1;
					if(nr % 131 == 0)
						System.err.print("\rread expr.csv  ... "+nr);
				} catch (Exception e) {
					e.printStackTrace();
					System.err.println("while processing \""+line+"\"");
				}
				line=expr.readLine();
				if(line==null) readAll=true;
			}
			if(nr>0)
				System.err.println("\rread expr.csv  ... "+nr);
			
			String outPattern = srcPattern+".tmp";
			if(readAll==true)
				outPattern=tgtPattern;
			
			nr=0;
			for(File f : sources) {
				BufferedReader in = new BufferedReader(new FileReader(f));
				File tgt = new File(f.getParentFile(), f.getName().replaceFirst(srcPattern,outPattern));
				if(tgt.exists()) {
					System.err.println("found "+tgt+", skipping");
				} else {
					System.err.print("\rwrite "+tgt+" ... "+nr+"          ");
					FileWriter out = new FileWriter(tgt);			
					for(line = in.readLine(); line!=null; line=in.readLine()) {
						out.write(line+"\n");
						if(line.contains("<expr id=")) {
							int e = Integer.parseInt(line.replaceFirst(".*id=\"([^\"]*)\".*","$1"));
							if(expr2langvar2txt.get(e)!=null)
								for(Integer d : expr2langvar2txt.get(e).keySet()) {
									out.write("<langvar id=\""+d+"\">\n");
									String t = expr2langvar2txt.get(e).get(d);
									out.write("<txt>"+t+"</txt>\n");
									nr=nr+1;
									if(nr % 131 == 0)
										System.err.print("\rwrite "+tgt+" ... "+nr);
									out.write("</langvar>\n");
								}
						}
					}
					System.err.print("\rwrite "+tgt+" ... "+nr+"          ");
					out.flush();
					out.close();
					in.close();
				}
			}
			System.err.println();
			expr2langvar2txt.clear();
			System.gc();
			if(!readAll) {
				addExpr(dir, outPattern, tgtPattern, expr);
				for(File tmp : getFiles(dir, outPattern)) 
					tmp.deleteOnExit();
			}
		}
	}

	static void addDefinition(File dir, String srcPattern, String tgtPattern, BufferedReader definition) throws IOException {

		List<File> sources = getFiles(dir, srcPattern);

		if(getFiles(dir,tgtPattern).size()==sources.size()) {
			System.err.println("addDefinition("+dir+", "+srcPattern+", "+tgtPattern+", Reader): all source files already converted, skipping");
		} else {

			long nr=0;
			System.err.print("read definition_class.csv ..");

			Hashtable<Integer,Hashtable<Integer,String>> meaning2langvar2txt = new Hashtable<Integer,Hashtable<Integer,String>>();
			
			String line = null;
			boolean readAll = false;
			try {
				line = definition.readLine();
			} catch (IOException e) {
				readAll=true;
			}
			while(line!=null & allocatedMemory()<0.8) {
				String[] fields = split(line);
				try {
					// id,meaning,langvar,txt
					int mng = Integer.parseInt(fields[1]);
					int langvar = Integer.parseInt(fields[2]);
					String txt = fields[3];
					if(meaning2langvar2txt.get(mng)==null)
						meaning2langvar2txt.put(mng, new Hashtable<Integer,String>());
					meaning2langvar2txt.get(mng).put(langvar, txt);
					nr=nr+1;
					if(nr % 131 == 0)
						System.err.print("\rread definition_class.csv  ... "+nr);
				} catch (Exception e) {
					e.printStackTrace();
					System.err.println("while processing \""+line+"\"");
				}
				line=definition.readLine();
				if(line==null) readAll=true;
			}
			if(nr>0)
				System.err.println("\rread definition_class ... "+nr);
			
			String outPattern = srcPattern+".tmp";
			if(readAll==true)
				outPattern=tgtPattern;
			
			nr=0;
			for(File f : sources) {
				BufferedReader in = new BufferedReader(new FileReader(f));
				File tgt = new File(f.getParentFile(), f.getName().replaceFirst(srcPattern,outPattern));
				if(tgt.exists()) {
					System.err.println("found "+tgt+", skipping");
				} else {
					System.err.print("\rwrite "+tgt+" ... "+nr+"          ");
					FileWriter out = new FileWriter(tgt);			
					for(line = in.readLine(); line!=null; line=in.readLine()) {
						out.write(line+"\n");
						if(line.contains("<meaning id=")) {
							int mng = Integer.parseInt(line.replaceFirst(".*id=\"([^\"]*)\".*","$1"));
							if(meaning2langvar2txt.get(mng)!=null)
								for(int l : meaning2langvar2txt.get(mng).keySet()) {
									String t = meaning2langvar2txt.get(mng).get(l);
									out.write("<langvar id=\""+l+"\">\n");
									out.write("<txt>"+t+"</txt>\n");									
									out.write("</langvar>\n");
									nr=nr+1;
									if(nr % 131 == 0)
										System.err.print("\rwrite "+tgt+"  ... "+nr);
								}
						}
					}
					System.err.print("\rwrite "+tgt+" ... "+nr+"          ");
					out.flush();
					out.close();
					in.close();
				}
			}
			System.err.println();
			meaning2langvar2txt.clear();
			System.gc();
			if(!readAll) {
				addDefinition(dir, outPattern, tgtPattern, definition);
				for(File tmp : getFiles(dir, outPattern)) 
					tmp.deleteOnExit();
			}
		}
	}
	
	static void addDenotationProp(File dir, String srcPattern, String tgtPattern, BufferedReader denotationProp) throws IOException {

		List<File> sources = getFiles(dir, srcPattern);
		if(getFiles(dir,tgtPattern).size()==sources.size()) {
			System.err.println("addDenotationProp("+dir+", "+srcPattern+", "+tgtPattern+", Reader): all source files already converted, skipping");
		} else {

			long nr=0;
			System.err.print("read denotation_prop.csv ..");
			Hashtable<Integer,Hashtable<Integer,Vector<String>>> denotation2expr2txt = new Hashtable<Integer,Hashtable<Integer,Vector<String>>>();
			
			String line = null;
			boolean readAll = false;
			try {
				line = denotationProp.readLine();
			} catch (IOException e) {
				readAll=true;
			}
			while(line!=null & allocatedMemory()<0.8) {
				String[] fields = split(line);
				try {
					int mng = Integer.parseInt(fields[1]);
					int e = Integer.parseInt(fields[2]);
					String txt = "";
					if(fields.length>3) txt=fields[3];
					if(denotation2expr2txt.get(mng)==null)
						denotation2expr2txt.put(mng,new Hashtable<Integer,Vector<String>>());
					if(denotation2expr2txt.get(mng).get(e)==null)
						denotation2expr2txt.get(mng).put(e,new Vector<String>());

					denotation2expr2txt.get(mng).get(e).add(txt);
					nr=nr+1;
					if(nr % 131 == 0)
						System.err.print("\rread denotation_prop.csv  ... "+nr);
				} catch (Exception e) {
					e.printStackTrace();
					System.err.println("while processing \""+line+"\"");
				}
				line=denotationProp.readLine();
				if(line==null) readAll=true;
			}
			if(nr>0)
				System.err.println("\rread denotation_prop.csv ... "+nr);
			
			String outPattern = srcPattern+".tmp";
			if(readAll==true)
				outPattern=tgtPattern;
			
			nr=0;
			for(File f : sources) {
				BufferedReader in = new BufferedReader(new FileReader(f));
				File tgt = new File(f.getParentFile(), f.getName().replaceFirst(srcPattern,outPattern));
				if(tgt.exists()) {
					System.err.println("found "+tgt+", skipping");
				} else {
					System.err.print("\rwrite "+tgt+" ... "+nr+"          ");
					FileWriter out = new FileWriter(tgt);			
					for(line = in.readLine(); line!=null; line=in.readLine()) {
						out.write(line+"\n");
						if(line.contains("<denotation id=")) {
							int mng = Integer.parseInt(line.replaceFirst(".*id=\"([^\"]*)\".*","$1"));
							if(denotation2expr2txt.get(mng)!=null)
								for(int e : denotation2expr2txt.get(mng).keySet()) {
									out.write("<denotation_prop>\n");
									out.write("<expr id=\""+e+"\">\n");
									for(String t : denotation2expr2txt.get(mng).get(e)) {
										out.write("<txt>"+t.replaceAll("\"\"", "\"").replaceFirst("^\"","").replaceFirst("\"$","")+"</txt>\n");
										nr=nr+1;
										if(nr % 131 == 0)
											System.err.print("\rwrite "+tgt+" ... "+nr);
									}
									out.write("</expr>\n");
									out.write("</denotation_prop>\n");
								}
						}
					}
					System.err.print("\rwrite "+tgt+" ... "+nr+"          ");
					out.flush();
					out.close();
					in.close();
				}
			}
			System.err.println();
			denotation2expr2txt.clear();
			System.gc();
			if(!readAll) {
				addDenotationProp(dir, outPattern, tgtPattern, denotationProp);
				for(File tmp : getFiles(dir, outPattern)) 
					tmp.deleteOnExit();
			}
		}
	}
	
	static void addDenotationClass(File dir, String srcPattern, String tgtPattern, BufferedReader denotationClass) throws IOException {

		List<File> sources = getFiles(dir, srcPattern);

		if(getFiles(dir,tgtPattern).size()==sources.size()) {
			System.err.println("addDenotationClass("+dir+", "+srcPattern+", "+tgtPattern+", Reader): all source files already converted, skipping");
		} else {

			long nr=0;
			System.err.print("read denotation_class.csv ..");
			Hashtable<Integer,Hashtable<Integer,Vector<Integer>>> denotation2srcEntry2tgtEntry = new Hashtable<Integer,Hashtable<Integer,Vector<Integer>>>();

			String line = null;
			boolean readAll = false;
			try {
				line = denotationClass.readLine();
			} catch (IOException e) {
				readAll=true;
			}
			while(line!=null & allocatedMemory()<0.8) {
				String[] fields = split(line);
				try {
					int mng = Integer.parseInt(fields[1]);
					int e1 = Integer.parseInt(fields[2]);
					int e2 = Integer.parseInt(fields[3]);
					if(denotation2srcEntry2tgtEntry.get(mng)==null)
						denotation2srcEntry2tgtEntry.put(mng, new Hashtable<Integer,Vector<Integer>>());
					if(denotation2srcEntry2tgtEntry.get(mng).get(e1)==null)
						denotation2srcEntry2tgtEntry.get(mng).put(e1, new Vector<Integer>());
					denotation2srcEntry2tgtEntry.get(mng).get(e1).add(e2);
					nr=nr+1;
					if(nr % 131 == 0)
						System.err.print("\rread denotation_class.csv  ... "+nr);
				} catch (Exception e) {
					e.printStackTrace();
					System.err.println("while processing \""+line+"\"");
				}
				line=denotationClass.readLine();
				if(line==null) readAll=true;
			}
			if(nr>0)
				System.err.println("\rread denotation_class ... "+nr);
			
			String outPattern = srcPattern+".tmp";
			if(readAll==true)
				outPattern=tgtPattern;
			
			nr=0;
			for(File f : sources) {
				BufferedReader in = new BufferedReader(new FileReader(f));
				File tgt = new File(f.getParentFile(), f.getName().replaceFirst(srcPattern,outPattern));
				if(tgt.exists()) {
					System.err.println("found "+tgt+", skipping");
				} else {
					System.err.print("\rwrite "+tgt+" ... "+nr+"          ");
					FileWriter out = new FileWriter(tgt);			
					for(line = in.readLine(); line!=null; line=in.readLine()) {
						out.write(line+"\n");
						if(line.contains("<denotation id=")) {
							int mng = Integer.parseInt(line.replaceFirst(".*id=\"([^\"]*)\".*","$1"));
							if(denotation2srcEntry2tgtEntry.get(mng)!=null)
								for(int e1 : denotation2srcEntry2tgtEntry.get(mng).keySet()) {
									out.write("<denotation_class>\n");
									out.write("<e1>\n<expr id=\""+e1+"\">\n");
									out.write("<e2>\n");
									for(int e2 : denotation2srcEntry2tgtEntry.get(mng).get(e1)) {
										out.write("<expr id=\""+e2+"\">\n</expr>");
										nr=nr+1;
										if(nr % 131 == 0)
											System.err.print("\rwrite "+tgt+"  ... "+nr);
									}
									out.write("</e2>\n");
									out.write("</expr>\n");
									out.write("</e1>\n");				
									out.write("</denotation_class>\n");
								}
						}
					}
					System.err.print("\rwrite "+tgt+" ... "+nr+"          ");
					out.flush();
					out.close();
					in.close();
				}
			}
			System.err.println();
			denotation2srcEntry2tgtEntry.clear();
			System.gc();
			if(!readAll) {
				addDenotationClass(dir, outPattern, tgtPattern, denotationClass);
				for(File tmp : getFiles(dir, outPattern)) 
					tmp.deleteOnExit();
			}
		}
	}
	
	static void addDenotation(File dir, String srcPattern, String tgtPattern, BufferedReader denotation) throws IOException {
		
		List<File> sources = getFiles(dir, srcPattern);
		
		if(getFiles(dir,tgtPattern).size()==sources.size()) {
			System.err.println("addDenotation("+dir+", "+srcPattern+", "+tgtPattern+", Reader): all source files already converted, skipping");
		} else {
			long nr=0;
			System.err.print("read denotation.csv ..");
			Hashtable<Integer,Hashtable<Integer,Integer>> meaning2deno2expr = new Hashtable<Integer,Hashtable<Integer,Integer>>();
			
			String line = null;
			boolean readAll = false;
			try {
				line = denotation.readLine();
			} catch (IOException e) {
				readAll=true;
			}

			while(line!=null && allocatedMemory()<0.8) {
				//System.err.print("\r"+(Runtime.getRuntime().totalMemory()-Runtime.getRuntime().freeMemory()) + " ("+allocatedMemory()+")    ");
				
				String[] fields = split(line);
				try {
					int deno = Integer.parseInt(fields[0]);
					int mng = Integer.parseInt(fields[1]);
					int e = Integer.parseInt(fields[2]);
					if(meaning2deno2expr.get(mng)==null)
						meaning2deno2expr.put(mng,new Hashtable<Integer,Integer>());
					meaning2deno2expr.get(mng).put(deno,e);
					nr=nr+1;
					if(nr % 131 == 0)
						System.err.print("\rread denotation.csv  ... "+nr);
				} catch (Exception e) {
					e.printStackTrace();
					System.err.println("while processing \""+line+"\"");
				}
				line=denotation.readLine();
				if(line==null) readAll=true;
			}
			if(nr>0)
				System.err.println("\rread denotation.csv  ... "+nr);
			
			String outPattern = srcPattern+".tmp";
			if(readAll==true)
				outPattern=tgtPattern;
			
			nr=0;
			for(File f : sources) {
				BufferedReader in = new BufferedReader(new FileReader(f));
				File tgt = new File(f.getParentFile(), f.getName().replaceFirst(srcPattern,outPattern));
				if(tgt.exists()) {
					System.err.println("found "+tgt+", skipping");
				} else {
					System.err.print("\rwrite "+tgt+" ... "+nr+"          ");
					FileWriter out = new FileWriter(tgt);			
					for(line = in.readLine(); line!=null; line=in.readLine()) {
						out.write(line+"\n");
						if(line.contains("<meaning id=")) {
							int mng = Integer.parseInt(line.replaceFirst(".*id=\"([^\"]*)\".*","$1"));
							if(meaning2deno2expr.get(mng)!=null)
								for(Integer d : meaning2deno2expr.get(mng).keySet()) {
									out.write("<denotation id=\""+d+"\">\n");
									Integer e = meaning2deno2expr.get(mng).get(d);
									out.write("<expr id=\""+e+"\">\n</expr>\n");
									nr=nr+1;
									if(nr % 131 == 0)
										System.err.print("\rwrite "+tgt+" ... "+nr);
									out.write("</denotation>\n");
								}
						}
					}
					System.err.print("\rwrite "+tgt+" ... "+nr+"          ");
					out.flush();
					out.close();
					in.close();
				}
			}
			System.err.println();
			meaning2deno2expr.clear();
			System.gc();
			if(!readAll) {
				addDenotation(dir, outPattern, tgtPattern, denotation);
				for(File tmp : getFiles(dir, outPattern)) 
					tmp.deleteOnExit();
			}
		}
	}
	
	static void addMeaningProp(File dir, String srcPattern, String tgtPattern, BufferedReader meaningProp) throws IOException {

		List<File> sources = getFiles(dir, srcPattern);
		if(getFiles(dir,tgtPattern).size()==sources.size()) {
			System.err.println("addMeaningProp("+dir+", "+srcPattern+", "+tgtPattern+", Reader): all source files already converted, skipping");
		} else {

			long nr=0;
			System.err.print("read meaning_prop.csv ..");
			Hashtable<Integer,Hashtable<Integer,Vector<String>>> meaning2expr2txt = new Hashtable<Integer,Hashtable<Integer,Vector<String>>>();
			
			String line = null;
			boolean readAll = false;
			try {
				line = meaningProp.readLine();
			} catch (IOException e) {
				readAll=true;
			}
			while(line!=null & allocatedMemory()<0.8) {
				String[] fields = split(line);
				try {
					int mng = Integer.parseInt(fields[1]);
					int e = Integer.parseInt(fields[2]);
					String txt = "";
					if(fields.length>3) txt=fields[3];
					if(meaning2expr2txt.get(mng)==null)
						meaning2expr2txt.put(mng,new Hashtable<Integer,Vector<String>>());
					if(meaning2expr2txt.get(mng).get(e)==null)
						meaning2expr2txt.get(mng).put(e,new Vector<String>());

					meaning2expr2txt.get(mng).get(e).add(txt);
					nr=nr+1;
					if(nr % 131 == 0)
						System.err.print("\rread meaning_prop.csv  ... "+nr);
				} catch (Exception e) {
					e.printStackTrace();
					System.err.println("while processing \""+line+"\"");
				}
				line=meaningProp.readLine();
				if(line==null) readAll=true;
			}
			if(nr>0)
				System.err.println("\rread meaning_prop.csv ... "+nr);
			
			String outPattern = srcPattern+".tmp";
			if(readAll==true)
				outPattern=tgtPattern;
			
			nr=0;
			for(File f : sources) {
				BufferedReader in = new BufferedReader(new FileReader(f));
				File tgt = new File(f.getParentFile(), f.getName().replaceFirst(srcPattern,outPattern));
				if(tgt.exists()) {
					System.err.println("found "+tgt+", skipping");
				} else {
					System.err.print("\rwrite "+tgt+" ... "+nr+"          ");
					FileWriter out = new FileWriter(tgt);			
					for(line = in.readLine(); line!=null; line=in.readLine()) {
						out.write(line+"\n");
						if(line.contains("<meaning id=")) {
							int mng = Integer.parseInt(line.replaceFirst(".*id=\"([^\"]*)\".*","$1"));
							if(meaning2expr2txt.get(mng)!=null)
								for(int e : meaning2expr2txt.get(mng).keySet()) {
									out.write("<meaning_prop>\n");
									out.write("<expr id=\""+e+"\">\n");
									for(String t : meaning2expr2txt.get(mng).get(e)) {
										out.write("<txt>"+t.replaceAll("\"\"", "\"").replaceFirst("^\"","").replaceFirst("\"$","")+"</txt>\n");
										nr=nr+1;
										if(nr % 131 == 0)
											System.err.print("\rwrite "+tgt+" ... "+nr);
									}
									out.write("</expr>\n");
									out.write("</meaning_prop>\n");
								}
						}
					}
					System.err.print("\rwrite "+tgt+" ... "+nr+"          ");
					out.flush();
					out.close();
					in.close();
				}
			}
			System.err.println();
			meaning2expr2txt.clear();
			System.gc();
			if(!readAll) {
				addMeaningProp(dir, outPattern, tgtPattern, meaningProp);
				for(File tmp : getFiles(dir, outPattern)) 
					tmp.deleteOnExit();
			}
		}
	}
	
	static void addMeaningClass(File dir, String srcPattern, String tgtPattern, BufferedReader meaningClass) throws IOException {

		List<File> sources = getFiles(dir, srcPattern);

		if(getFiles(dir,tgtPattern).size()==sources.size()) {
			System.err.println("addMeaningClass("+dir+", "+srcPattern+", "+tgtPattern+", Reader): all source files already converted, skipping");
		} else {

			long nr=0;
			System.err.print("read meaning_class.csv ..");
			Hashtable<Integer,Hashtable<Integer,Vector<Integer>>> meaning2srcEntry2tgtEntry = new Hashtable<Integer,Hashtable<Integer,Vector<Integer>>>();

			String line = null;
			boolean readAll = false;
			try {
				line = meaningClass.readLine();
			} catch (IOException e) {
				readAll=true;
			}
			while(line!=null & allocatedMemory()<0.8) {
				String[] fields = split(line);
				try {
					int mng = Integer.parseInt(fields[1]);
					int e1 = Integer.parseInt(fields[2]);
					int e2 = Integer.parseInt(fields[3]);
					if(meaning2srcEntry2tgtEntry.get(mng)==null)
						meaning2srcEntry2tgtEntry.put(mng, new Hashtable<Integer,Vector<Integer>>());
					if(meaning2srcEntry2tgtEntry.get(mng).get(e1)==null)
						meaning2srcEntry2tgtEntry.get(mng).put(e1, new Vector<Integer>());
					meaning2srcEntry2tgtEntry.get(mng).get(e1).add(e2);
					nr=nr+1;
					if(nr % 131 == 0)
						System.err.print("\rread meaning_class.csv  ... "+nr);
				} catch (Exception e) {
					e.printStackTrace();
					System.err.println("while processing \""+line+"\"");
				}
				line=meaningClass.readLine();
				if(line==null) readAll=true;
			}
			if(nr>0)
				System.err.println("\rread meaning_class ... "+nr);
			
			String outPattern = srcPattern+".tmp";
			if(readAll==true)
				outPattern=tgtPattern;
			
			nr=0;
			for(File f : sources) {
				BufferedReader in = new BufferedReader(new FileReader(f));
				File tgt = new File(f.getParentFile(), f.getName().replaceFirst(srcPattern,outPattern));
				if(tgt.exists()) {
					System.err.println("found "+tgt+", skipping");
				} else {
					System.err.print("\rwrite "+tgt+" ... "+nr+"          ");
					FileWriter out = new FileWriter(tgt);			
					for(line = in.readLine(); line!=null; line=in.readLine()) {
						out.write(line+"\n");
						if(line.contains("<meaning id=")) {
							int mng = Integer.parseInt(line.replaceFirst(".*id=\"([^\"]*)\".*","$1"));
							if(meaning2srcEntry2tgtEntry.get(mng)!=null)
								for(int e1 : meaning2srcEntry2tgtEntry.get(mng).keySet()) {
									out.write("<meaning_class>\n");
									out.write("<e1>\n<expr id=\""+e1+"\">\n");
									out.write("<e2>\n");
									for(int e2 : meaning2srcEntry2tgtEntry.get(mng).get(e1)) {
										out.write("<expr id=\""+e2+"\">\n</expr>");
										nr=nr+1;
										if(nr % 131 == 0)
											System.err.print("\rwrite "+tgt+"  ... "+nr);
									}
									out.write("</e2>\n");
									out.write("</expr>\n");
									out.write("</e1>\n");							
									out.write("</meaning_class>\n");
								}
						}
					}
					System.err.print("\rwrite "+tgt+" ... "+nr+"          ");
					out.flush();
					out.close();
					in.close();
				}
			}
			System.err.println();
			meaning2srcEntry2tgtEntry.clear();
			System.gc();
			if(!readAll) {
				addMeaningClass(dir, outPattern, tgtPattern, meaningClass);
				for(File tmp : getFiles(dir, outPattern)) 
					tmp.deleteOnExit();
			}
		}
	}
	
	/** requires *.source.xml files in dir, srcPattern and tgtPattern are substrings that specify the naming patterns, first instance of srcPattern must be replaced by tgtPattern */
	static void addMeaning(File dir, String srcPattern, String tgtPattern, BufferedReader meaning) throws IOException {

		List<File> sources = getFiles(dir, srcPattern);

		if(getFiles(dir,tgtPattern).size()==sources.size()) {
			System.err.println("addMeaning("+dir+", "+srcPattern+", "+tgtPattern+", Reader): all source files already converted, skipping");
		} else {
			
			System.err.print("read meaning.csv ..");
			Hashtable<Integer,Vector<Integer>> source2meaning = new Hashtable<Integer,Vector<Integer>>();
			long nr = 0;
			String line = null;
			boolean readAll = false;
			try {
				line = meaning.readLine();
			} catch (IOException e) {
				readAll=true;
			}
			
			while(line!=null && allocatedMemory()<0.8) {
				String[] fields = line.split(",");
				int src = Integer.parseInt(fields[1]);
				int mng = Integer.parseInt(fields[0]);
				if(source2meaning.get(src)==null)
					source2meaning.put(src, new Vector<Integer>());
				source2meaning.get(src).add(mng);
				nr=nr+1;
				if(nr % 131 == 0)
					System.err.print("\rread meaning.csv ... "+nr);
				line=meaning.readLine();
				if(line==null) readAll=true;
			} 
			if(nr>0)
				System.err.println("\rread meaning.csv ... "+nr);
			
			String outPattern = srcPattern+".tmp";
			if(readAll==true)
				outPattern=tgtPattern;
			
			nr=0;
			for(File f : sources) {
				BufferedReader in = new BufferedReader(new FileReader(f));
				File tgt = new File(f.getParentFile(), f.getName().replaceFirst(srcPattern,outPattern));
				if(tgt.exists()) {
					System.err.println("found "+tgt+", skipping");
				} else {
					System.err.print("\rwrite "+tgt+" ... "+nr+"          ");
					FileWriter out = new FileWriter(tgt);			
					for(line = in.readLine(); line!=null; line=in.readLine()) {
						out.write(line+"\n");
						if(line.contains("<source id=")) {
							int src = Integer.parseInt(line.replaceFirst(".*id=\"([^\"]*)\".*","$1"));
							if(source2meaning.get(src)!=null)
								for(int m : source2meaning.get(src)) {
									out.write("<meaning id=\""+m+"\">\n</meaning>\n");
									if(nr % 131 == 0)
										System.err.print("\rwrite "+tgt+" ... "+nr+"          ");
									nr=nr+1;
								}
						}
					}
					System.err.print("\rwrite "+tgt+" ... "+nr+"          ");
					out.flush();
					out.close();
					in.close();
				}
			}
			System.err.println();		
			source2meaning.clear();
			System.gc();
			if(!readAll) {
				addMeaning(dir, outPattern, tgtPattern, meaning);
				for(File tmp : getFiles(dir, outPattern)) 
					tmp.deleteOnExit();
			}
		}
	}
	
	public static void main(String[] argv) throws Exception {
		System.err.println("synopsis: PanLex DIR\n"+
			"read PanLex directory (unzipped archive), retrieve sources, retrieve their data, split the database\n"+
				"to run on a slim machine, we create a document skeleton, and rewrite it with one table at a time only,\n"+
			"and continue until all content has been assigned\n"+
			"process input tables by chunks that fit into main memory");
		
		String dir = argv[0];
		
		long nr=0;
		BufferedReader in;
		
		File source = new File("sources");
		if(source.exists()) {
			System.err.println("found "+source+", keeping it");
		} else {
			System.err.println("create "+source);
					
			in = new BufferedReader(new FileReader(dir+"/source.csv"));
			String[] cols = in.readLine().split(",");
			for(String line=in.readLine(); line!=null; line=in.readLine()) {
				String[] fields = split(line);
				File subdir = new File(source, fields[0].replaceFirst("^(..).*","$1").trim());
				File filedir = new File(subdir, fields[0]);
				filedir.mkdirs();
				File f = new File(filedir, fields[0]+".source.xml");
				FileWriter out = new FileWriter(f);
				out.write("<source");
				for(int i = 0; i<fields.length; i++)
					if(!fields[i].trim().equals(""))
						out.write(" "+cols[i]+"=\""+fields[i]+"\"");
				out.write(">\n");
				out.write("</source>\n");
				out.flush();
				out.close();
			}
			in.close();
		}
		
		in = new BufferedReader(new FileReader(dir+"/meaning.csv"));
		in.readLine(); // skip headline
		addMeaning(source, ".source.xml", ".meaning.xml", in);
		in.close();
		for(File f : getFiles(source,".source.xml"))
			f.deleteOnExit();

		in = new BufferedReader(new FileReader(dir+"/meaning_class.csv"));
		in.readLine(); // skip headline
		addMeaningClass(source, ".meaning.xml", ".meaning_class.xml", in);
		in.close();
		for(File f : getFiles(source,".meaning.xml"))
			f.deleteOnExit();

		in = new BufferedReader(new FileReader(dir+"/meaning_prop.csv"));
		in.readLine(); // skip headline
		addMeaningProp(source, ".meaning_class.xml", ".meaning_prop.xml", in);
		in.close();
		for(File f : getFiles(source,".meaning_class.xml"))
			f.deleteOnExit();
		
		in = new BufferedReader(new FileReader(dir+"/denotation.csv"));
		in.readLine(); // skip headline
		addDenotation(source, ".meaning_prop.xml", ".denotation.xml", in);
		in.close();
		for(File f : getFiles(source,".meaning_prop.xml"))
			f.deleteOnExit();

		in = new BufferedReader(new FileReader(dir+"/denotation_class.csv"));
		in.readLine(); // skip headline
		addDenotationClass(source, ".denotation.xml", ".denotation_class.xml", in);
		in.close();
		for(File f : getFiles(source,".denotation.xml"))
			f.deleteOnExit();

		in = new BufferedReader(new FileReader(dir+"/denotation_prop.csv"));
		in.readLine(); // skip headline
		addDenotationProp(source, ".denotation_class.xml", ".denotation_prop.xml", in);
		in.close();
		for(File f : getFiles(source,".denotation_class.xml"))
			f.deleteOnExit();
		
		in = new BufferedReader(new FileReader(dir+"/definition.csv"));
		in.readLine(); // skip headline
		addDefinition(source, ".denotation_prop.xml", ".definition.xml", in);
		in.close();
		for(File f : getFiles(source,".denotation_prop.xml"))
			f.deleteOnExit();
		
		in = new BufferedReader(new FileReader(dir+"/expr.csv"));
		in.readLine(); // skip headline
		addExpr(source, ".definition.xml", ".expr.xml", in);
		in.close();
		for(File f : getFiles(source,".definition.xml"))
			f.deleteOnExit();
		
		in = new BufferedReader(new FileReader(dir+"/source_langvar.csv"));
		in.readLine(); // skip headline
		addSourceLangvar(source, ".expr.xml", ".source_langvar.xml", in);
		in.close();
		for(File f : getFiles(source,".expr.xml"))
			f.deleteOnExit();
		
		in = new BufferedReader(new FileReader(dir+"/source_format.csv"));
		in.readLine(); // skip headline
		addSourceFormat(source, ".source_langvar.xml", ".source_format.xml", in);
		in.close();
		for(File f : getFiles(source,".source_langvar.xml"))
			f.deleteOnExit();

		in = new BufferedReader(new FileReader(dir+"/format.csv"));
		in.readLine(); // skip headline
		addFormat(source, ".source_format.xml", ".format.xml", in);
		in.close();
		for(File f : getFiles(source,".source_format.xml"))
			f.deleteOnExit();

		in = new BufferedReader(new FileReader(dir+"/langvar.csv"));
		in.readLine(); // skip headline
		addLangvar(source, ".format.xml", ".extracted.xml", in);
		in.close();
		for(File f : getFiles(source,".format.xml"))
			f.deleteOnExit();
	}
	
	protected static String[] split(String line) {
		line=line.replaceAll("\\s+", " ");
		String result = "";
		boolean quoted = false;
		while(line.length()>0) {
 			String s = line.substring(0,1);
 			line = line.substring(1);
 			if(s.equals("\"")) {
 				quoted=!quoted;
 				s="";
 			}
 			if(s.equals("\t")) s="    "; 			// expand tabs
 			if(s.equals(",") && !quoted) s="\t";
 			result=result+s;
		}
		return result.split("\t");
	}
}