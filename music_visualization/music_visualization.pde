import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer player;
AudioMetaData meta;
BeatDetect beat;
int r = 200;
float rad = 70;

void setup() {
    // size(displayWidth, displayHeight);
    size(400, 300);
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
    fill(#1A1F18, 20);

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
    
    // ビートが検出されたときにtrue
    if (beat.isOnset()) rad = rad * 0.9;
    else rad = 70;

    ellipse(0, 0, 2 * rad, 2 * rad);
    // stroke(-1, 50);
    // int bsize = player.bufferSize();
}
