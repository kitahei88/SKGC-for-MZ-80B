# SKGC for SHARP MZ-80B
**Super Kolour Graphic Card kit for MZ-80B**

**Make your MZ-80B to MZ-2000+MZ-1R01(GRAM)!**

**No more need to plant bombs at Sharp corporation!**

## これはなんですか？ ##

往年の名機であるSHARPのMZ-80BをMZ-2000+MZ-1R01（MZ-2200相当）にするキットです。

MZ-80BとMZ-2000は多少の差があるのみで殆ど同じような設計です。
その差分を埋め、更には現代のICを使用することでMZ-2000＋MZ-1R01（GRAM3プレーン）という状態まで内蔵する形で設計しました。

作成には多くのパーツ、それぞれのICをへの書き込み用ツールが必要なため、パーツ実装のみならず、設計するためのツールを揃えるだけでも結構ハードルは高いです。

作成方法の解説は行いません。（作成に伴った不具合への対応が困難なため）

回路図、ソース、それぞれのICへの書き込み方法など不明な場合は別サイトの[ブログ](http://kitahei88.blog.fc2.com/)にて完成品を頒布していますので検討ください。

## ライセンスと一般的注意事項 ##

これらの回路図およびソフトウェア群はkitahei88, Takuya Fukudaにより作成された同人ハードウェア、ソフトウェアであり、使用、作成に関しては以下の一般的な注意事項に了承を得たものとします。
またマニュアルに記載されている内容は開発段階のものを含み、実際の動作などは改変により異なることがあります。

ライセンスは三条項BSDライセンスとします。詳細は[LICENSE](https://github.com/kitahei88/SKGC-for-MZ-80B/blob/main/LICENSE)を参考ください。
以下、同人ハードウェアとしての一般的な使用前同意事項について記載します。

**・ハードウェアの回路図、ソフトウェア群とも無償公開しますが、同時に無保証です。**

使用により発生した損害（パソコンやディスク、ドライブが壊れた、データが破壊されたなど）に関しては一切責任を負わないものとします。


**・サポートは最低限であり、修正が必要なバグがある可能性があります。**

将来的に重大なバグなどが見つかる可能性があります。それらに対しての情報公開は行いますが、個別環境へのサポートは各自で行っていただく必要があります。


**・使用、作成には「ある程度の知識、技術」が必要です。**

回路図、ソースなどは公開していますが、作成する過程での一般的質問にはお答えしません。

上記したように完成品の頒布を行いますが、将来的に欠陥が認められた場合や改良が必要な場合が発生しても、修正情報を提供しますが個別にこちらで修正は行いません。自ら修正することが必要になります。


**・異常な動作（発熱など）に注意を払い、電源管理など十分に行って下さい。**

頒布する基板もパターンなどはむき出しです。自ら作成された場合などもパターンのショートなどで、発熱や発火の危険があります。これらによる何らかの損害が発生しても、責任を負わないものとします。十分に注意されて使用してください。

## 謝辞 ##
** AVRソフトウェア開発 **

AVR日本語情報サイト　えーう゛ぃあーる どっと　じぇーぴー

http://www.avr.jp/

日本語翻訳されたデータシートを参考にしました

## 動作環境 ##
動作するMZ-80Bが必要です。
CMTやディスプレイはMZ_80B本体のものを使用します。
それらを修理やメンテナンスして、外部からCMTのエミュレーションを行うような実装にしていたり、ディスプレイを外部の液晶などへ表示するようにしていた場合の動作は保証外です。
MZ-80Bの動作を変更したり、改善したりするものではありません。
（例:MZ-80B用のGRAMの機能は無いため、MZ-80BのGRAMは別で取り付ける必要がある）
（将来的にCMTの代替ハードを取り付けられるように設計してありますが、現在は未実装です）
またMZ-2000（MZ-2200）のアプリケーションやソフトウェアは別途ご自身で用意が必要です。

## 開発環境　使用アプリケーションについて ##
**AVR**

AVRはAtmega88を使用しています。

Microchip社の[Microchip Studio](https://www.microchip.com/en-us/tools-resources/develop/microchip-studio)にて開発しています。

バイナリとして.hexファイルもアップしていますので、書き込みのみを行うのであれば、それを使用してください。FUSEビットに付いてはソース内に記載があります。


**SPLD**

Microchip社のATF16V8Cを使用しています。

開発はMicrochip社の[WinCUPL](https://www.microchip.com/en-us/products/fpgas-and-plds/spld-cplds/pld-design-resources)を使用しています。

書き込みのために.jedファイルをアップしていますので、書き込みのみ行うのであれば、それを利用してください。


**CPLD**

Xilinx社のXC95144XLを使用しています。

開発には[Xilinx ISE 14.7](https://japan.xilinx.com/products/design-tools/ise-design-suite/ise-webpack.html)を使用しています。

こちらも書き込みのために.jedファイルをアップしてありますので、利用してください。


**回路図　基板**

RSコンポーネンツ社が提供している[DesignSparkPCB](https://www.rs-online.com/designspark/pcb-software-jp)を使用しています。

DesignSparkPCBのプロジェクトファイルを置いてありますので、それで開いてください。

回路図の参照やManufacture plotで基板作成できるようにしていあります。


## 取り付け方法 ##
Docフォルダ内の[HowToConnect.md](./Doc/HowToConnect.md)を参照にしてください。

## 使用方法 ##
Docフォルダ内の[HowToUse.md](./Doc/HowToUse.md)を参照にしてください。

スイッチを切り換えるだけです。

**スイッチの切り換えは必ず電源を切った状態で行ってください。**


## FAQ ##
**〜というソフトは動きますか？FDDなどでも使えますか？**

正直所有していない環境、ソフトウェアで動作することは確認できません。
残念ながらFDDに関してはボードなど一切所有していないので不明です。

人柱でチャレンジして報告してもらえると助かります。

**なんでKolour？**

なんとなく

**8255の基板にある12ピンのコネクターはなんですか？**

8255のCMT周りのインターフェースを外部へ取り出すようにしています。

将来的にMZ-80BのCMTユニットをエミュレーションするようなデバイスを考えており、その拡張として接続できるようにしていますが、現在は妄想段階で全く予定がありません。

**GRAMにある後ろのジャンパと2ピンのコネクターはなんですか？**

これは現在の動作モードの出力するためのコネクターです。

ジャンパーは単純に切り換えるスイッチの出力をするのか、切り換わった状態を出力するのかを変更するためにあります。
（MZ-2000モードにスイッチを切り換えていたとして、IPL動作時にMZ-2000かMZ-80Bかを切り換えるためです）

これを使うとyanatakaさんの作成された[MZ-2000_SD](https://github.com/yanataka60/MZ-2000_SD)がMZ-80BでもMZ-2000でもROMを切り換えるスイッチに入力させることで、自動で切り換えて使えます。
なんのことかわかんない場合は放置でおｋ

## 改版履歴 ##
2023.1.25
初版
