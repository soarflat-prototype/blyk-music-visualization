import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer player;
AudioMetaData meta;
BeatDetect beat;
int radius = 200;
float rad = 70;

void setup() {
    size(displayWidth, displayHeight);
    // size(400, 300);
    minim = new Minim(this);
    beat = new BeatDetect();
    player = minim.loadFile("sample.mp3");
    meta = player.getMetaData();
    player.loop();
    background(-1);
    // カーソルを非表示にする
    noCursor();
}

void draw() {
    /**
     * ある範囲から別の範囲に数値を再マップする
     * @example
     *   map(50, 0, 100, 0, 200) 
     *    return 100
     * 0~100の範囲で50の数値を、0~200の範囲の数値に再マップするので100になる
     */ 
    float t = map(mouseX, 0, width, 0, 1);

    /** 
     * player.mixに格納されているオーディオバッファのサンプルを分析する
     */
    beat.detect(player.mix);

    // 塗りつぶしの色を設定
    fill(#1A1F18);

    // 線は描画しないようにする
    noStroke();

    // 画面サイズの四角形を描画
    rect(0, 0, width, height);

    // 座標を中央に移動
    translate(width / 2, height / 2);

    // 塗りつぶしをしないようにする
    noFill();

    // 塗りつぶしの色を設定
    fill(-1, 10);
    
    // ビートが検出されたらradを乗算する
    if (beat.isOnset()) rad = rad * 0.9;
    else rad = 70;
    ellipse(0, 0, 2 * rad, 2 * rad);

    // サウンドオブジェクトのバッファサイズを取得
    int bufferSize = player.bufferSize();

    // 線の色を設定
    stroke(-1);


    /** 
     * 円弧上に波形データを描画
     * bufferSizeが1024であり、i += 5なので
     * 1024 / 5 = 241本の波形データに基づいた線が描画される
     */
    for (int i = 0; i < bufferSize; i += 5) {
        /** 
         * bufferSizeとiからラジアンを算出する
         * ラジアン = 2 * PI * (度数 / 360)
         * なので
         * ラジアン = 2 * PI * (i / bufferSize)
         */
        float radian = 2 * PI * i / bufferSize;

        /** 
         * 線を引き始めるx, y座標
         */
        float x = radius * cos(radian);
        float y = radius * sin(radian);

        /** 
         * 線を引く方向のx, y座標を取得
         * radiusにスケーリングした波形データを加算する
         * player.left.get()とplayer.right.get()によって返される値は-1と1の間にあり
         * 波形データを見え易く描画するためにはwindowの大きさに応じてスケーリングする必要がある
         * 今回、スケーリングのために100を乗算している
         */
        float x2 = (radius + player.left.get(i) * 100) * cos(radian);
        float y2 = (radius + player.left.get(i) * 100) * sin(radian);

        line(x, y, x2, y2);
    }
    
    beginShape();
    noFill();
    stroke(-1, 50);

    for (int i = 0; i < bufferSize; i += 30) {
        float radian = 2 * PI * i / bufferSize;
        float x2 = (radius + player.left.get(i) * 100) * cos(radian);
        float y2 = (radius + player.left.get(i) * 100) * sin(radian);

        vertex(x2, y2);
        pushStyle();
        stroke(-1);
        strokeWeight(2);
        point(x2, y2);
        popStyle();
    }

    endShape();
}
