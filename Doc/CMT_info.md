# MZ-80BとMZ-2000のCMT制御信号について

MZ-80BとMZ-2000は8255のPORTでCMT制御を行います。
読み込みデータや書き込みデータなどは割愛し、まずMZ-80Bのテープの制御信号につて記載します。

MZ-80BのオーナーズマニュアルにあるCMT周りの回路図をみるとおおよその動作はわかります。
それぞれの8255のポートとマニュアル中の信号名は以下です。
PA0	BLK2
PA1	BLK1
PA2	PNL
PA3	STOP
PC4	OPEN
PC5	REW
PC6	WRITE

回路図を見ながらのほうがわかりやすいと思いますので、オーナーズマニュアルを所有している方は、CMTの制御回路のところを参照ください。
まず、BLK1,BLK2,REW,PNLは74LS74のフリップフロップに入っています。
BLK1とREWはIC3007の74LS74に、DとしてBLK1、CKとしてREWが入力されています。
BLK2はIC3011にCKとして入力されています。
PNLはIC3007のCKとして入力されています。

これらはすべてSTOPによってClearされます。
BLK1はFFかREWかの方向を指定する信号です。BLK1をHにするとFF,LにするとREWとなります。
このBLK1を出力し続けた状態で、REWをLからHに変化させると、フリップフロップなのでラッチされます。
ラッチした状態で、BLK2をLからHに変化させると、モーターの動作が開始され、FFもしくはREWになります。
これらのラッチされた信号はすべてSTOPの信号がくるとリセットされます。

PNLはカセットテープを通常のPLAY（READ)もしくはREC(WRITE)の状態で動作させます。

つまり、いくつかの信号の組み合わせでテープの動作を制御しているのがMZ-80Bです。

次に、MZ-2000は8255を介してテープの制御回路へ入出力を行っていることは同一ですが、テープの制御自体をTC9121Pというテープデッキコントローラーを使って制御しています。
ですので、8255は単純にそれぞれのTC9121Pへの信号をそれぞれ接続する形で入出力しているだけなので、MZ-2000の回路図とTC9121Pのデータシートを見ると動作がわかりやすいです。

MZ-2000のオーナーズマニュアルにある8255のポートと信号名は以下です。

PA0	_REW
PA1	_FF
PA2	_PLAY
PA3	_STOP
PA5	_AREW
PA6	_APLAY
PA7	_APSS-P
PC5	KINH
PC6	_REC

PB3	TAPE END

信号が負論理になっているのはTC9121Pが負論理のためだと思います。
_REWなどは名前のままなのでよいかなと思います。
_AREWと_APLAY、_APSS-Pについてですが、TC9121Pのマニュアルによると、TC9121PのX,Y,Zの入力の状態で動作が変化します。
この内、Zはテープの動作中はH、停止するとLになる、PB3のTAPE END信号の反転したものです。
X,Yに関してはMZ-2000ではOFF（NC)ですのでデータシートから以下のことがわかります。

両方ともHの場合、FF,REW,PLAYの動作は通常通りテープの終端に到達すると停止します。
_AREWのみLの場合、FFとREWはテープの終端で停止し、PLAYはテープの終端にくるとREW動作になります(そのREWではテープの終端で停止します）
_APLAYのみLの場合、PLAY,FFはテープの終端で停止し、REWでテープの終端で停止した後、PLAY動作になります。（そのPLAY動作は終端で停止します。）
_APLAY,_AREWともにLの場合、FFは影響を受けず、PLAYで終端まで行った後はREW動作になり、REWで終端に来た後はPLAYになります（PLAY,REWを繰り返す）

_APSSの信号はPLAYソレノイド（テープのヘッドをテープに接触させる）をオン、オフさせるための信号です。
当然PLAYやRECでは_APSSに関係なくソレノイドはオンになりますが、それ以外FFやREW中でオンにしてテープの早送り、プログラムの頭出しなどに使います。
タイミングはオーナーズマニュアルに書いてあるとおりです。

これらを踏まえて、AVRで制御信号を変換するようにしました。
TAPE ENDはテープカウンターの停止状態をチェックして作成して8255へ入力しています。
