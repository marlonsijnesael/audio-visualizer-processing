public class Grid {
    public int maxHeight;
    public int scale;
    public int rows;
    public int cols;
    public float soundScale;
    public float colorScale;
    public PVector col;

    public Grid(int _maxHeight, int _scale, int _rows, int _cols, PVector _col) {
        maxHeight = _maxHeight;
        scale = _scale;
        rows = _rows;
        cols = _cols;
        col = _col;
        }

    public void Display(float _soundScale, float _colorScale) {
        soundScale = _soundScale;
        colorScale = _colorScale;

        pushMatrix();
        pushStyle();
        //fill(255* colorScale,0,0);
        noFill();
        stroke(col.x * colorScale, col.y, col.z * colorScale);
        strokeWeight(0.5);
        //scale for coloring the edges and for changing the height of the vertices -> based on amplitude of the microphone input  
        //create grid with nested for loop, set vertices in a triangle strip 

        for (int y = 0; y < rows; y++) {
            beginShape(TRIANGLE_STRIP);
            //stroke(_col.x * _colorScale,_col.y,_col.z * _colorScale);
            for (int x = 0; x < cols; x++) {
                //set a random height and multiply it with the soundScale variable to make scale it between 0 times and 1 times the random number
                vertex(x * scale, y * scale, (random(0, maxHeight) * _soundScale));
                vertex(x * scale, (y + 1) * scale, (random(0, maxHeight) * _soundScale));

                }
            endShape();
            //  fill(255* colorScale,0,0);

            }
        popStyle();
        popMatrix();
        }
    }
