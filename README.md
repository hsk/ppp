# ppp

パッケージシステムを考えてみる

言語処理系を作る場合に、コンパイラやランタイムを揃えるのも大事ですが、パッケージシステムもまた大事です。
ここでは、そのパッケージシステムの仕組みを考えてみます。

## npmを考える。

たとえば、a.jsというファイルがあったときに、出来るだけ最小のコマンドでパッケージを作れるようにする事を考えます。

	$ node a.js

と、入力すると出来れば、依存関係をみて全ソースの依存関係を見て、ビルドして、ないファイルがあれば、パッケージシステムにアクセスして、自動的にパッケージをダウンロード＆インストールして、リンクしてくれると嬉しい。

	$ node -test a.js
	
とするとテスト出来て、

	$ node -push a.js

で、バックアップとれて

	$ node -release aaa.js

で、パッケージがリリース出来たら嬉しいわけです。
コンパイラさえあれば、他は何もいらないと。
そうはいっても、コンパイラ作るだけでも大変だし、テストツール作るのも大変だし、パッケージシステムを作るだけでも大変です。
だから、パッケージシステムは別なコマンドとして作るのがよいわけです。

	$ npm
	
というコマンドがそれをやってくれるわけですね。


次に、以下のように入力するだけで自動的にリリースしてくれる事を考えましょう。

	$ npm aaa.js

これは残念ながら、情報不足です。まず、パッケージ名が分かりません。

```package.json
{
	"name": "aaa"
}
```

という具合です。

コマンド一覧を表示した時の事を考えれば、バージョン情報や、説明も必要ですね。

```package.json
{
	"name": "aaa",
	"version": "1.0.0",
	"description": "aaa is test package"
}
```

誰が作ったのか分からないのは、信用出来ないです。必要ですよね。

```package.json
{
	"name": "aaa",
	"version": "1.0.0",
	"description": "aaa is test package",
	"author": {
		"name": "hsk",
		"email": "sakurai777@gmail.com"
	}
}
```

依存関係も欲しいですね。バージョン情報で制限も加えられると良いですね。

```package.json
{
	"name": "aaa",
	"version": "1.0.0",
	"description": "aaa is test package",
	"author": {
		"name": "hsk",
		"email": "sakurai777@gmail.com"
	},
	"repository": {
		"type": "git",
		"url":"https://github.com/hsk/aaa"
	},
	"dependencies": {"bbb":"1.0.0","ccc":"1.0.0"}
}
```

また、URLも分かりません。リポジトリのタイプも設定出来る事にしましょう。

```package.json
{
	"name": "aaa",
	"version": "1.0.0",
	"description": "aaa is test package",
	"author": {
		"name": "hsk",
		"email": "sakurai777@gmail.com"
	},
	"repository": {
		"type": "git",
		"url":"https://github.com/hsk/aaa"
	},
	"dependencies": {"bbb":"1.0.0","ccc":"1.0.0"},
	"bin": "./bin/aaa",
	"main": "aaa.js"
}
```

実行ファイルがあるなら、その名前も必要ですね。
メインファイル名も必要ですね。

```package.json
{
	"name": "aaa",
	"version": "1.0.0",
	"description": "aaa is test package",
	"author": {
		"name": "hsk",
		"email": "sakurai777@gmail.com"
	},
	"repository": {
		"type": "git",
		"url":"https://github.com/hsk/aaa"
	},
	"dependencies": {"bbb":"1.0.0","ccc":"1.0.0"},
	"bin": "./bin/aaa",
	"main": "aaa.js"
}
```

これが、npmのpackage.jsonです。

## opamを考える。

opamはocamlのパッケージシステムです。ocamlのパッケージシステムは歴史的に複数存在しています。なのでopamは他のパッケージシステムで作ったパッケージを含む事が出来るような作りになっています。

opamを作る場合の事を考えてみます。

パッケージはバージョンによって動作が異なる可能性があります。
だから、バージョン毎にパッケージは別々に作成する必要があります。

パッケージ名/パッケージ名.バージョン

のディレクトリにパッケージ用のファイルをおく事にします。
古いバージョンでは動いたのに、新しいバージョンでは動かないよ。では困る訳です。

descrには説明を書こう。説明は改行も入れたいだろうしね。

```descr
	aaa is test package
```

findlibに自分のパッケージ名を書くことにしよう。

```findlib
	aaa
```

urlにはtar.gzファイルのファイル名とチェックサムを書く事にしましょう。

```url
archive: "https://github.com/mirage/ocaml-base64/archive/v1.0.0.tar.gz"
checksum: "9a64caa88a8464f4567a5a96f9cf7e0c"
```

opam にその他の情報をまとめます。opamはバージョンアップするかもしれないので、バージョン情報を書く事にしましょう。

```opam
opam-version: "1"
```
メンテナのメールアドレスと、作った人の情報を書こう。チームで作るかもしれないし、作った人は複数対応できるようにしよう。

```opam
opam-version: "1"
maintainer: "sakurai777@gmail.com"
authrs: ["Hiroshi Sakurai"]
```

ライセンスも必要だね。

```opam
opam-version: "1"
maintainer: "sakurai777@gmail.com"
authrs: ["Hiroshi Sakurai"]
license: "MIT"
```

ビルド方法も書こう。configureしてmakeしてmake installするとか、順番に色々書けると良いよね。

```opam
opam-version: "1"
maintainer: "sakurai777@gmail.com"
authrs: ["Hiroshi Sakurai"]
license: "MIT"
build: [
  ["configure"]
  ["make"]
  ["make" "install"]
]
```

削除方法も欲しい。

```opam
opam-version: "1"
maintainer: "sakurai777@gmail.com"
authrs: ["Hiroshi Sakurai"]
license: "MIT"
build: [
  ["configure"]
  ["make"]
  ["make" "install"]
]
remove : [
  ["ocamlfind" "remove" "aaa"]
]
```

依存関係も書けると良いね。ocamlfindが必要だからかいとこう。

```opam
opam-version: "1"
maintainer: "sakurai777@gmail.com"
authrs: ["Hiroshi Sakurai"]
license: "MIT"
build: [
  ["configure"]
  ["make"]
  ["make" "install"]
]
remove : [
  ["ocamlfind" "remove" "aaa"]
]
depends: [
  "ocamlfind"
]
```

これが、opamの考え方です。

## homebrew

homebrewはmacのosxのパッケージシステムです。rubyでdryでかけたらいいのにっていうシステムです。

homebrewでは、rubyでは全てがオブジェクトです。なので、パッケージもまたオブジェクトで作れば良いと考えます。

したがって、パッケージ名=ファイル名であり、クラス名です。
homebrewのパッケージはFormulaと呼びます。
Formulaを作るので、Formulaを継承して作る事になります。

```aaa.rb
require "formula"

class Aaa < Formula
end
```

このクラスに色々書き込めば良いようにします。
世の中はgitであり、Formulaはgitにおかれて当然です。gitのアカウントを持っているならば、連絡はgitで取れば良いのだから、emailアドレス等は不要です。作った人の名前も不要だ。説明なんてなくてもいいよね。
必要最小限でいい。でも、バイナリでインストール出来たら嬉しいので、bottleという名前のファイルをおけるようにしよう。インストール方法も楽なメソッドでちょいちょいっとつくれば作れるようにしよう。
ということで以下のような感じで書けば動きます。

```aaa.rb
require "formula"

class Aaa < Formula
  url "https://github.com/hsk/aaa.git"
  homepage "http://github.com/hsk/aaa"
  head "https://github.com/hsk/aaa.git"
  sha1 ""
  version '1.0.0'

  bottle do
    cellar :any
    root_url "https://raw.githubusercontent.com/hsk/homebrew-tap/master/bottles"
    sha1 "6b9d72bd574832ab3c9eeca331c573dcb55ea8b9" => :mavericks
  end

  def install
    system "make all"
    bin.install Dir["aaa/aaa"]
  end

end
```

## オリジナルのパッケージシステムを考えます。pppを作ります。

さて、このように色々と見てきました。brewの全てはオブジェクトは面白いし、githubベースな所も楽しいです。
メールアドレスも何もいらない所もなんか、楽で良いです。楽しましょう。
urlとバージョン情報とインストール方法さえ書けばいい感じに思えます。

```aaa.json
{
  "name":"aaa",
  "user":"hsk",
  "repo":"aaa",
  "version":"1.0.0",
  "install":[
    ["make"],
    ["make install"],
  ],
  "depends":{"bbb":"1.0.0"}
}
```

```bbb.json
{
  "name":"bbb",
  "user":"hsk",
  "repo":"bbb",
  "version":"1.0.0",
  "install":[
    ["make"],
    ["make install"],
  ],
  "depends":{}
}
```

これだけあれば、とりあえず、十分じゃないでしょうか。
問題は無いでしょうか？うーん。ファイルはまとまってあった方が嬉しいです。
リポジトリ沢山作るのもいいんですけど、リポジトリ内に複数パッケージ作れても良い気がするんですよね。
めんどくさいし。


```aaa/ppp.json
{
  "name":"aaa",
  "user":"hsk",
  "repo":"ppp/aaa",
  "version":"1.0.0",
  "install":[
    ["make"],
    ["make install"],
  ],
  "depends":{"bbb":"1.0.0"}
}
```

```bbb/ppp.json
{
  "name":"bbb",
  "user":"hsk",
  "repo":"ppp/bbb",
  "version":"1.0.0",
  "install":[
    ["make"],
    ["make install"],
  ],
  "depends":{}
}
```

