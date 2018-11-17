//class for sphere that will deform by using the amplitude of the right instrument
public class PopSphere {

    public int size;
    public boolean instrument;
    public PVector col;
    public float soundScale;
    public float colorScale;
    public PVector position;
    
    //constructor
    public PopSphere(int _size, boolean _instrument, PVector _col) {
        size = _size;
        instrument = _instrument;
        col = _col;
        }

    //void for displaying the sphere
    public void Display(float _soundScale, float _colorScale, PVector _position, float _rotation) {
        soundScale = _soundScale;
        colorScale = _colorScale;
        if (instrument) {
            pushMatrix();
            pushStyle();
            translate(_position.x, _position.y, _position.z);
            rotate(_rotation);
            //fill(0,0,255);
            // noFill();
            stroke(col.x, col.y * colorScale, col.z * colorScale);
            sphereDetail(((int)soundScale * (int) colorScale));
            sphere(size * fft.getBand((int)random(0, fft.specSize())));
            popStyle();
            popMatrix();

            }
        }

    }
