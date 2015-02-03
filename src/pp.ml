#use "ppp.ml";;

ppp {
	name = "aaa";
	user = "hsk";
	repo = "ppp/aaa";
	version = "1.0.0";
	install = ["make";"make install"];
	uninstall = ["make uninstall"];
	depends = [("bbb","1.0.0")]
};;
