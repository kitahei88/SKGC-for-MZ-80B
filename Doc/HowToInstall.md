# 取り付け方法 
頒布したセットの取り付け方法を記載します。画像はクリックすると別タブで大きい画像で表示されます。

<img src="images/1.jpg" width="300" />

まずMZ-80B本体の電源を確実に切り、電源ケーブルを外してください。

<img src="images/2.jpg" width="300" />

次に背面二ヶ所のネジを外し、CMTとモニター部分を上方へ押し上げ、本体をあけます。

<img src="images/3.jpg" width="300" /><img src="images/4.jpg" width="300" />

CMTとモニター部分のカバーを5箇所のネジを外して開けます。

<img src="images/5.jpg" width="300" /><img src="images/6.jpg" width="300" /><img src="images/7.jpg" width="300" />

この際、モニター周囲は高圧が掛かっている可能性が高く、注意してください。最悪、指に穴が空きます。

<img src="images/8.jpg" width="300" />

写真にあるCMT制御基板のコネクターを外します。これはテープカウンターの動作信号が入ってくるところで、これでテープが回転しているかを入力しています。

<img src="images/9.jpg" width="300" /><img src="images/10.jpg" width="300" />

ここにセットのケーブルをつけて取り込みます。

<img src="images/11.jpg" width="300" /><img src="images/12.jpg" width="300" /><img src="images/13.jpg" width="300" />

ケーブルはCMT基板のすぐ下にある、電源からのコードが通じている穴を通して、メインのマザーボード側へ誘導します。

<img src="images/14.jpg" width="300" /><img src="images/15.jpg" width="300" /><img src="images/16.jpg" width="300" /><img src="images/17.jpg" width="300" />

この段階でCMTとモニター部分のカバーを元通り取り付けます。ネジで止めても問題ありません。

<img src="images/18.jpg" width="300" /><img src="images/19.jpg" width="300" />


次にマザーボード側の取り付けを行います。
拡張I/OボードのMZ-8BKが取り付けられている場合、これを外さないとマザーボードが取り外せません。
まず、拡張I/Oボード背面のパネルを取り外します。

<img src="images/20.jpg" width="300" /><img src="images/21.jpg" width="300" />

次に拡張I/Oボード用の電源を引き抜き、マザーボードと固定されているネジを取り外して引き抜きます。

<img src="images/22.jpg" width="300" /><img src="images/23.jpg" width="300" /><img src="images/24.jpg" width="300" />

マザーボードを取り外します。
マザーボードから伸びている、電源コード、CMT、キーボード、CMTコントロールボタン、リセット、ディスプレイ信号などのケーブルをすべて取り外します。取り外しには力が必要だったり、爪で固定されているなどしているので、上手く外してください。

<img src="images/25.jpg" width="300" /><img src="images/26.jpg" width="300" /><img src="images/27.jpg" width="300" />

次にマザーボードと背面のパネルを固定してる2箇所のネジを取り外します。

<img src="images/28.jpg" width="300" /><img src="images/29.jpg" width="300" />

そうすることで、マザーボードを背面にスライドさせることで取り外すことができます。

<img src="images/30.jpg" width="300" /><img src="images/31.jpg" width="300" /><img src="images/32.jpg" width="300" />

マザーボードには以下の4枚のカードを取り付けます。

<img src="images/33.jpg" width="300" />


***
*IPL起動時からMZ-2000として起動する基板も追加する場合は*
*この斜体の項目を追加してください*
*もう一つある、こちらの基板をIC8 BOOT-ROMの場所に取り付けます。*

*こちらには27C32などのEPROMにMZ-2000とMZ-80BのIPLをまとめて書き込んだものを取り付けます。*
*EPROMの詳細は[IPL.md](./IPL.md)を参照ください*

*こちらから2芯のケーブルを取り付けます。*
****



IC43 G#3にはこの基板を取り付けます。

<img src="images/34.jpg" width="300" />

まず該当のICを取り外してください。このとき、ピン曲がりや折れに注意してください。

<img src="images/35.jpg" width="300" /><img src="images/36.jpg" width="300" />

基板を写真の向きで取り付け、ICをソケットにはめ込みます。

<img src="images/37.jpg" width="300" /><img src="images/38.jpg" width="300" />

このパーツ部分はMZ-80Bのキーボードの直下になり、不用意に高さがあるとキーボードの基板に干渉します。
その場合、ショートしたりするため、MZ-80Bが起動しない、キー入力ができないなどの不具合が出ることがあります。
しっかりはめ込んで、もし必要であればICのピン部分をマスキングしてください。（しっかりはめ込めば不要な高さとなるように設計しています）

<img src="images/39.jpg" width="300" />

このときも基板を割らないように、ピンを折らないように注意してください。コネクターには３芯のケーブルを取り付けて、拡張ボード側へ誘導します。

<img src="images/40.jpg" width="300" /><img src="images/41.jpg" width="300" /><img src="images/42.jpg" width="300" />

IC2　G#1も同様です。
ICを取り外した後、基板を取り付け、ICを基板上のソケットにはめ込み、5芯のケーブルを取り付けてください。

<img src="images/43.jpg" width="300" /><img src="images/44.jpg" width="300" />

<img src="images/45.jpg" width="300" /><img src="images/46.jpg" width="300" /><img src="images/47.jpg" width="300" /><img src="images/48.jpg" width="300" />

CN13はGRAMを取り付ける10ピンのところです。

<img src="images/49.jpg" width="300" />

基板を取り付けて8芯のケーブルを取り付けてください。
写真の向きに取り付けます。
MZ-80BのGRAMを取り付けていた場合は、この基板上にあるコネクターにもともとの取り付け向きと同じように取り付けてください
（これはマザーボードなどをもとに戻した後に行います）

<img src="images/50.jpg" width="300" /><img src="images/51.jpg" width="300" /><img src="images/52.jpg" width="300" /><img src="images/53.jpg" width="300" />


最後はIC23　8255です。
これも同じようにピン曲がりなどに気をつけてICを取り外します。

<img src="images/54.jpg" width="300" /><img src="images/55.jpg" width="300" />

周囲のパーツの関係でこの基板のピンは長く作成しています。
曲がったり折れやすいので注意してはめ込んでください。
<img src="images/56.jpg" width="300" /><img src="images/57.jpg" width="300" />

同様に8255も基板のソケットにはめ込みます。
こちらには3本のケーブルを挿入します。

4芯ケーブルは良いとして、2ピンのケーブルが２ヶ所あります。
中央の2ピンのコネクターはKINHを出力しています。こちらはCMTコントロールボタンへ向かうケーブルに割り込ませる形のケーブルを装着します。
そしてもう一方の端の2ピンのコネクターには、CMTカウンターの信号を入力しますので、先程CMT基板に取り付けたケーブルをこちらへ誘導して装着します。
この2芯ケーブル2本はマザーを戻してからのほうが良いと思われます。

<img src="images/58.jpg" width="300" />


以上の4枚の基板を装着したら、マザーボードをスライドさせながらもとの位置へ戻し、２ヶ所のネジで止めます。

<img src="images/59.jpg" width="300" /><img src="images/60.jpg" width="300" /><img src="images/61.jpg" width="300" />

この状態で、先程取り外したケーブル類をもとに戻していきます。
奥から戻したほうが楽です。

<img src="images/62.jpg" width="300" />

そして、先程取り付けた8255の残り２ヶ所のケーブルを取り付けます。
KINHのケーブルはCMTコントロールケーブルへ割り込ませる形で、CMTカウンターのケーブルとも装着します。

<img src="images/63.jpg" width="300" /><img src="images/64.jpg" width="300" />

<img src="images/65.jpg" width="300" />

最後にマザーボードの電源ケーブルを取り付けたか確認してください。
マザーボードへの取り付けは完了です。

<img src="images/66.jpg" width="300" />


次に拡張I/Oボードの取り付けを行います。もし拡張I/Oボードを持っていない場合はスキップしてください。

先程と逆に、拡張I/Oボードを取り付け、マザーボードとの間で2箇所のネジ止めを行います。
電源ケーブルをマザーボードへ取り付けます。

<img src="images/67.jpg" width="300" /><img src="images/68.jpg" width="300" /><img src="images/69.jpg" width="300" />

後ろのパネルはカードを取り付けるまで閉じないでください。
GRAMのカードを取り付けます。
マザーボードから複数のケーブルを装着する必要があるので、一番上のどちらかに装着してください。
背面から向かって左側がよいと思います。

<img src="images/70.jpg" width="300" /><img src="images/71.jpg" width="300" />

こちらを装着したら、それぞれのケーブルをそれぞれのソケットへ装着します。

***
*IPLの差し込む部位はこの写真にありません*
***


<img src="images/72.jpg" width="300" />

MZ-80BのGRAMがある場合はこれを取り付けてください。

<img src="images/73.jpg" width="300" /><img src="images/74.jpg" width="300" /><img src="images/75.jpg" width="300" />

ここまで行ったら、パネルを閉じてOKです。
CMT、ディスプレイを下へ戻し、ネジ止めしたら終了です。

<img src="images/76.jpg" width="300" /><img src="images/77.jpg" width="300" /><img src="images/78.jpg" width="300" />

拡張I/Oボードを所有していない場合、基板はフリーな状態となりますが使用可能です。
40ピンのストレートケーブル（古いIDEのケーブルなど）で拡張I/Oボードの取り付けするコネクターからGRAMへそのままケーブルを取り付けます。

<img src="images/79.jpg" width="300" />

頒布する基板にはケーブル取り付けのピンヘッダは含まれていませんので、ケーブルとピンヘッダを入手してはんだ付けしてください。

<img src="images/80.jpg" width="300" />

問題は電源ですが、外部で+5V電源を供給することで使用できるようにしています。

<img src="images/81.jpg" width="300" />

内部の電源をもらっても良いのですが、拡張I/Oボードへの電源のコネクターが入手できません。
そのほかのマザーからの信号線は同様に取り付けます。
基板がむき出しなのでショートしないようにしてください。

<img src="images/82.jpg" width="300" />

以上です。
お疲れ様でした。
