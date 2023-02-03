## 使用方法 ##

GRAM背面にあるスイッチを切り換えることで、MZ-80Bとして動作するかMZ-2000としての動作かを切り換えます。
切り換え時は必ず電源を切った状態で行ってください。


取り付け直後では、まずMZ-80Bモードが動作するか確認してください。
GRAMにあるスイッチをMZ-80B側にして電源を投入します。
![IMG_20230202_213719155](https://user-images.githubusercontent.com/8729286/216513704-583772e5-2ff8-47b1-afaa-e03fd2b2bb43.jpg)
CMTが開くとか、CMTを読みに行く、BASICを読み込んだ後に巻き戻す、何かソフトウェアを読み込んで動作を確認するなどしてください。
![IMG_20230202_213914421](https://user-images.githubusercontent.com/8729286/216513772-71c546fa-287e-4bae-831a-0c08deef063a.jpg)
![IMG_20230202_215122552](https://user-images.githubusercontent.com/8729286/216513797-444d13e0-0674-48ca-9143-99ca9bdf90e0.jpg)

次にMZ-2000のモードをチェックします。
電源を切った後にスイッチをMZ-2000側に切り換えます。
![IMG_20230202_215220343](https://user-images.githubusercontent.com/8729286/216513844-fd4e44c5-cf1b-4253-b42e-a6b55388b1fb.jpg)

画面はグリーンモニターにも表示されますが、外部にminiDsub15ピンで接続するとカラーで表示されます。
同期信号はもともとのMZ-2000と同様に15KHzが出力されるようにしていますので、15KHzでRGB信号が入力可能なLCDを使用してください。
例：
HsyncとVsyncはそれぞれ出力されています、Csyncではありません。

この状態で電源を投入すると、外部モニターには白字で表示されると思います。
MZ-2000のBASICやソフトなどを読み込んでチェックしてみてください。

![IMG_20230202_224407020](https://user-images.githubusercontent.com/8729286/216513902-3c3f306e-1192-48b9-859e-69176c071ed7.jpg)

![IMG_20230202_235755446](https://user-images.githubusercontent.com/8729286/216513956-1940549b-f399-49f6-81ee-fae42c72be0f.jpg)

上手く画面表示、動作するのであれば完成です。
お疲れ様でした。

