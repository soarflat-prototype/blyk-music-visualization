import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer player;
AudioMetaData meta;
BeatDetect beat;
int RADIUS = 200;
float radius = RADIUS;
float CENTER_CIRCLE_RADIUS = 70;
float centerCircleRadius = CENTER_CIRCLE_RADIUS;

void setup() {
    size(800, 800);
    minim = new Minim(this);
    beat = new BeatDetect();
    player = minim.loadFile("sample.mp3");
    player.loop();
    player.setGain(-10);
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

    radius = RADIUS * player.left.level() * pow(1.2, 3) + 150;
    centerCircleRadius = CENTER_CIRCLE_RADIUS * player.right.level() * pow(1.5, 3) + 50;
    
    // ビートが検出されたらradを乗算する
    // if (beat.isOnset()) centerCircleRadius = centerCircleRadius * 0.9;
    // else centerCircleRadius = 70;
    ellipse(0, 0, 2 * centerCircleRadius, 2 * centerCircleRadius);

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
        float sample = (i < bufferSize / 2)
            ? player.left.get(i) 
            : player.right.get(i);
        if (sample < 0) sample = 0;
        float x2 = (radius + (sample * 100)) * cos(radian);
        float y2 = (radius + (sample * 100)) * sin(radian);

        line(x, y, x2, y2);
    }
    
    beginShape();
    noFill();
    stroke(-1, 50);

    for (int i = 0; i < bufferSize; i += 30) {
        float radian = 2 * PI * i / bufferSize;
        float sample = (i < bufferSize / 2)
            ? player.left.get(i) 
            : player.right.get(i);
        float x2 = (radius + sample * 100) * cos(radian);
        float y2 = (radius + sample * 100) * sin(radian);

        vertex(x2, y2);
        pushStyle();
        stroke(-1);
        strokeWeight(2);
        point(x2, y2);
        popStyle();
    }

    endShape();

    for (int i = 0; i < bufferSize; i += 5) {
         /** 
         * bufferSizeとiからラジアンを算出する
         * ラジアン = 2 * PI * (度数 / 360)
         * なので
         * ラジアン = 2 * PI * (i / bufferSize)
         */
        float radian = 2 * PI * i / bufferSize;

        /** 
         * pointを描画するx, y座標を取得
         * radiusにスケーリングした波形データを加算する
         * player.left.get()とplayer.right.get()によって返される値は-1と1の間にあり
         * 波形データを見え易く描画するためにはwindowの大きさに応じてスケーリングする必要がある
         * 今回、スケーリングのために200を乗算している
         */
        float sample = (i < bufferSize / 2)
            ? player.left.get(i) 
            : player.right.get(i);

        /** 
         * sampleが0未満の場合、radiusより内側に描画がされてしまう
         *
         * 例えばradiusが200の時にsampleをスケーリングした値を加算して
         * その値にcos(radians(0))を乗算してx座標を求めたいとする
         * x = (200 + (sample * 200)) * cos(radians(0));
         * 
         * sampleが1の場合、xは400になり、sampleが-1の場合xは0になる
         * そのため、sampleが0未満の場合x座標がradiusが内側になってしまう
         * 今回はそれをしたくないため、sampleが0未満の場合、0にする
         */
        if (sample < 0) sample = 0;
        float x2 = (radius + (sample * 200)) * cos(radian);
        float y2 = (radius + (sample * 200)) * sin(radian);

        pushStyle();
        stroke(-1);
        strokeWeight(2);
        point(x2, y2);
        popStyle();
    }
}
