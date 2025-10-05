using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Math as Math;

class HelloWorldView extends Ui.View {

    const GAP_OFFSETS = [ -40, -15, 15, -25, 25, 5, -5, 35 ];

    var viewWidth;
    var viewHeight;

    var birdX;
    var birdY;
    var birdRadius = 10;
    var birdVelocity;

    var gravity = 0.8;
    var jumpVelocity = -7.5;

    var pipeX;
    var pipeWidth = 28;
    var pipeGapY;
    var pipeGapHeight = 90;
    var pipeSpeed = 3;
    var gapIndex = 0;

    var score = 0;
    var isGameOver = false;
    var needsReset = true;
    var hasStarted = false;

    function initialize() {
        View.initialize();
    }

    function onShow() {
        needsReset = true;
        Ui.requestUpdate();
    }

    function onUpdate(dc) {
        updateDimensions(dc);

        if (needsReset) {
            resetGame();
            needsReset = false;
        }

        if (!isGameOver) {
            updateGameState();
        }

        drawScene(dc);

        if (!isGameOver) {
            Ui.requestUpdate();
        }
    }

    function handleInput() {
        if (isGameOver) {
            resetGame();
            Ui.requestUpdate();
            return;
        }

        hasStarted = true;
        birdVelocity = jumpVelocity;
        Ui.requestUpdate();
    }

    function onTap(position) {
        handleInput();
        return true;
    }

    function updateDimensions(dc) {
        if (viewWidth == null) {
            viewWidth = dc.getWidth();
        }

        if (viewHeight == null) {
            viewHeight = dc.getHeight();
        }
    }

    function resetGame() {
        birdX = viewWidth / 4;
        birdY = viewHeight / 2;
        birdVelocity = 0;

        pipeX = viewWidth + pipeWidth;
        pipeSpeed = Math.max(2, viewWidth / 120.0);
        pipeGapHeight = Math.max(60, Math.min(viewHeight * 0.55, 90));
        gapIndex = 0;
        pipeGapY = nextGapCenter();

        score = 0;
        isGameOver = false;
        hasStarted = false;
    }

    function updateGameState() {
        if (!hasStarted) {
            return;
        }

        birdVelocity += gravity;
        birdY += birdVelocity;

        pipeX -= pipeSpeed;

        if (pipeX + pipeWidth < 0) {
            pipeX = viewWidth + pipeWidth;
            pipeGapY = nextGapCenter();
            score += 1;
        }

        if (birdY - birdRadius < 0) {
            birdY = birdRadius;
            isGameOver = true;
            return;
        } else if (birdY + birdRadius > viewHeight) {
            birdY = viewHeight - birdRadius;
            isGameOver = true;
            return;
        }

        var halfGap = pipeGapHeight / 2;
        var withinPipeX = (birdX + birdRadius) > pipeX && (birdX - birdRadius) < (pipeX + pipeWidth);

        if (withinPipeX) {
            if ((birdY - birdRadius) < (pipeGapY - halfGap) || (birdY + birdRadius) > (pipeGapY + halfGap)) {
                isGameOver = true;
            }
        }
    }

    function drawScene(dc) {
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();

        drawPipes(dc);
        drawBird(dc);
        drawScore(dc);

        if (isGameOver) {
            drawGameOver(dc);
        } else if (!hasStarted) {
            drawInstructions(dc);
        }
    }

    function drawPipes(dc) {
        var halfGap = pipeGapHeight / 2;
        var topPipeHeight = pipeGapY - halfGap;
        var bottomPipeY = pipeGapY + halfGap;

        var pipeXPos = Math.round(pipeX);
        var topHeight = Math.max(0, Math.round(topPipeHeight));
        var bottomY = Math.round(bottomPipeY);
        var bottomHeight = Math.max(0, viewHeight - bottomY);

        dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_BLACK);
        dc.fillRectangle(pipeXPos, 0, pipeWidth, topHeight);
        dc.fillRectangle(pipeXPos, bottomY, pipeWidth, bottomHeight);
    }

    function drawBird(dc) {
        dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_BLACK);
        dc.fillCircle(Math.round(birdX), Math.round(birdY), birdRadius);
    }

    function drawScore(dc) {
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        var scoreText = "Score: " + score;
        dc.drawText(
            viewWidth / 2,
            20,
            Gfx.FONT_SMALL,
            scoreText,
            Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawGameOver(dc) {
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(
            viewWidth / 2,
            viewHeight / 2 - 12,
            Gfx.FONT_MEDIUM,
            Ui.loadResource(Rez.Strings.GameOver),
            Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
        );

        dc.drawText(
            viewWidth / 2,
            viewHeight / 2 + 18,
            Gfx.FONT_SMALL,
            Ui.loadResource(Rez.Strings.RestartPrompt),
            Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawInstructions(dc) {
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(
            viewWidth / 2,
            viewHeight / 2,
            Gfx.FONT_SMALL,
            Ui.loadResource(Rez.Strings.TapToFlap),
            Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
        );
    }

    function nextGapCenter() {
        var offset = GAP_OFFSETS[gapIndex];
        gapIndex = (gapIndex + 1) % GAP_OFFSETS.size();

        var halfGap = pipeGapHeight / 2;
        var minY = halfGap + 10;
        var maxY = viewHeight - halfGap - 10;

        var target = viewHeight / 2 + offset;

        if (target < minY) {
            target = minY;
        } else if (target > maxY) {
            target = maxY;
        }

        return target;
    }

}
