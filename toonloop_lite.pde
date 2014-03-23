/**
 * Toonloop :: Live Stop Motion Animation Tool. 
 * @version Toonloop Lite version 0.15 Cleaned up.
 * @author Alexandre Quessy <alexandre@quessy.net>
 * @license GNU Public License version 2
 * @url http://www.toonloop.com
 * 
 * In the left window, you can see what is seen by the live camera.
 * In the right window, it is the result of the stop motion loop.
 * 
 * Usage : 
 *  - Press space bar to grab a frame.
 *  - Press DELETE or BACKSPACE to delete the last frame.
 *  - Press 'r' to reset and start the current sequence. (an remove all its frames)
 *  - Press 's' to save the current sequence as a QuickTime movie.
 *  - Press 'p' to open the Quicktime video camera settings dialog. (if available)
 *  - Press 'a' to toggle on/off the auto recording. (it records one frame on every frame)
 *  - Press 'q' to quit (disabled)
 *  - Press UP to increase frame rate
 *  - Press DOWN to decrease frame rate
 *  - Press numbers from 0 to 9 to switch to an other sequence.
 */

// UNCOMMENT If on Mac or Windows:
import processing.video.*;
Capture cam;
// UNCOMMENT If on GNU/Linux:
/*
//import codeanticode.gsvideo.*;
GSCapture cam;
*/
int LOOP_MAX_NUM_FRAME = 500;
int NUM_SEQUENCES = 10; 
int LOOP_WIDTH = 320;
int LOOP_HEIGHT = 240;
int FRAME_RATE = 8;
float WINDOW_SIZE_RATIO = 1.5;
int SAVED_MESSAGE_DURATION = 30;
float SAVED_MESS_SIZE_RATIO = 0.5;
int TEXT_FONT_SIZE = 24;
boolean ENABLE_QUIT = false;
int ONION_PEEL_ALPHA = 63;
// UNCOMMENT if on Mac or Windows:
// -------------------------------
//Choose only one of the followings: 
//int LOOP_CODEC = MovieMaker.H263;
//int LOOP_CODEC = MovieMaker.H264;
//int LOOP_CODEC = MovieMaker.MOTION_JPEG_A;
int LOOP_CODEC = MovieMaker.MOTION_JPEG_B;
//int LOOP_CODEC = MovieMaker.ANIMATION;
// --------------------------------
//Choose only one of the followings: 
//int LOOP_QUALITY = MovieMaker.HIGH;
int LOOP_QUALITY = MovieMaker.BEST;
//int LOOP_QUALITY = MovieMaker.LOSSLESS;
MovieMaker movieOut;
int currentSeq = 0;
PFont font;
int is_auto_recording = 0;
int isFlashing = 0;
int is_displaying_saved_message = 0;

String saved_file_name;
ToonSequence sequences[] = new ToonSequence[NUM_SEQUENCES];

void setup() 
{
  size((int)(LOOP_WIDTH*2*WINDOW_SIZE_RATIO), (int)(LOOP_HEIGHT*2*WINDOW_SIZE_RATIO)); 
  frameRate(FRAME_RATE);
  // UNCOMMENT If on Mac or Windows:
  cam = new Capture(this, LOOP_WIDTH, LOOP_HEIGHT);
  println("Available cameras :");
  //print(Capture.list());
  // end of Mac or Windows 
  // UNCOMMENT If on GNU/Linux:
  /*
  cam = new GSCapture(this, LOOP_WIDTH, LOOP_HEIGHT);
  println("Cannot list cameras on GNU/Linux");
  */
  // end of GNU/Linux
  for (int i = 0; i < sequences.length; i++) {
    sequences[i] = new ToonSequence();
  }
  font = loadFont("CourierNewPSMT-24.vlw");
  println("Welcome to ToonLoop ! The Live Stop Motion Animation Tool.");
  println(")c( Alexandre Quessy 2008");
  println("http://alexandre.quessy.net");
}

void draw() 
{
  background(0);
  if (cam.available() == true) 
  {
    cam.read();
  }
  noTint(); // alpha 100%
  textFont(font, TEXT_FONT_SIZE);
  if (is_auto_recording == 1) 
  {
    sequences[currentSeq].addFrame();
    fill(255,0,0,255);
    String warningText = "AUTO RECORDING";
    text(warningText, (int)(LOOP_WIDTH/(4*WINDOW_SIZE_RATIO)),(int)(LOOP_HEIGHT*1.7*WINDOW_SIZE_RATIO));
  } else {
    fill(255,255,255,255);
    if (isFlashing == 1) 
    {
      isFlashing = 0;
      rect(0, (LOOP_HEIGHT/2)*WINDOW_SIZE_RATIO, LOOP_WIDTH*WINDOW_SIZE_RATIO,LOOP_HEIGHT*WINDOW_SIZE_RATIO);
      tint(255, 191); // alpha 75%
    } 
  }
  tint(255, 255, 255, 255);
  image(cam, 0,(int)((LOOP_HEIGHT/2)*WINDOW_SIZE_RATIO), 
      (int)(LOOP_WIDTH*WINDOW_SIZE_RATIO), (int)(LOOP_HEIGHT*WINDOW_SIZE_RATIO));
  tint(255, 255, 255, 255); 
  fill(127);
  textFont(font, TEXT_FONT_SIZE);
  int y = (int)(LOOP_HEIGHT*1.6*WINDOW_SIZE_RATIO);
  if (sequences[currentSeq].captureFrameNum > 0)
  {
    text(""+sequences[currentSeq].captureFrameNum, (int)((LOOP_WIDTH/2)*WINDOW_SIZE_RATIO), y);
    text(""+(sequences[currentSeq].playFrameNum+1), (int)((LOOP_WIDTH*3/2.0)*WINDOW_SIZE_RATIO), y);
    
  }
  fill(127,0,0); // darker
  text(""+(currentSeq+1), (int)((LOOP_WIDTH)*WINDOW_SIZE_RATIO), y);
  fill(255);
  // Image at the current offset in the loop on the right:
  noTint();
  if (sequences[currentSeq].captureFrameNum > 0) 
  { 
    image(
      sequences[currentSeq].images[sequences[currentSeq].playFrameNum], 
      (int)(LOOP_WIDTH*WINDOW_SIZE_RATIO), (int)((LOOP_HEIGHT/2)*WINDOW_SIZE_RATIO), 
      (int)(LOOP_WIDTH*WINDOW_SIZE_RATIO), (int)(LOOP_HEIGHT*WINDOW_SIZE_RATIO));
    sequences[currentSeq].loopFrame();
  }
  
  // SAVED message
  textFont(font, (int)(TEXT_FONT_SIZE*SAVED_MESS_SIZE_RATIO));
  if (is_displaying_saved_message > 0)
  {
    is_displaying_saved_message--; // decrement duration
    int x = (int)((LOOP_WIDTH/4)*WINDOW_SIZE_RATIO); 
    int the_y = (int)(LOOP_HEIGHT*1.7*WINDOW_SIZE_RATIO);
    fill(255,0,0,255);
    text("Saved to "+saved_file_name + ". ("+LOOP_WIDTH +"x"+ LOOP_HEIGHT+")", x,the_y);
  }
}

void keyPressed() 
{
  switch (keyCode)
  {
    case UP:
      increaseFrameRate();
      break;
    case DOWN:
      decreaseFrameRate();
      break;
    case LEFT:
      break;
    case RIGHT:
      break;
  }
  
  switch (key)
  {
    case ' ': // ADD FRAME
      if (is_auto_recording == 0) {
        sequences[currentSeq].addFrame();
      }
      break;
    case 'p': // SETTINGS
      cameraPreferences();
      break;
    case 'r': // RESET
      sequences[currentSeq].resetMovie();
      break;
    case 's':
      if (is_auto_recording == 0) {
        saveMovie();
      }
      break;
    case BACKSPACE: // DELETE ONE FRAME
    case DELETE:
      sequences[currentSeq].deleteFrame();
      break;
    case 'a': // AUTO RECORD
      toggleAutoRecording();
      break;
    case 'q': // QUIT APPLICATION
      if (ENABLE_QUIT) {
        exit();
      }
      break;
    case '0':
      switchToSequence(0);
      break;
    case '1':
      switchToSequence(1);
      break;
    case '2':
      switchToSequence(2);
      break;
    case '3':
      switchToSequence(3);
      break;
    case '4':
      switchToSequence(4);
      break;
    case '5':
      switchToSequence(5);
      break;
    case '6':
      switchToSequence(6);
      break;
    case '7':
      switchToSequence(7);
      break;
    case '8':
      switchToSequence(8);
      break;
    case '9':
      switchToSequence(9);
      break;  
  }
}
// switches to an other sequence
void switchToSequence(int i) 
{
   if (NUM_SEQUENCES > i && i >= 0)
    {
        currentSeq = i;
        FRAME_RATE = sequences[currentSeq].getFrameRate();
        frameRate(FRAME_RATE);
    }
}
void cameraPreferences()
{
  println("Opening the settings window. (if available)");
  // Works only on Mac and Windows:
  //cam.settings();
}

void increaseFrameRate() 
{
  changeFrameRate(sequences[currentSeq].getFrameRate()+1);
}

void decreaseFrameRate() 
{
  changeFrameRate(sequences[currentSeq].getFrameRate()-1);
}

void changeFrameRate(int r) 
{
      if (r > 0 && r <= 60) 
      {
        FRAME_RATE = r;
        frameRate(FRAME_RATE);
        sequences[currentSeq].setFrameRate(FRAME_RATE);
      }
}

void toggleAutoRecording()
{
    if (is_auto_recording ==0) 
    {
      is_auto_recording = 1;
    } else {
      is_auto_recording = 0;
    }
}
/**
One sequence (bin)
 */
class ToonSequence
{
  int captureFrameNum = 0; //the next captured frame number ... might wrap around
  int playFrameNum = 0;
  PImage[] images = new PImage[LOOP_MAX_NUM_FRAME];
  int seqFrameRate = FRAME_RATE;
  int getFrameRate() 
  {
    return seqFrameRate;
  }
  void setFrameRate(int r)
  {
    seqFrameRate = r;
  }
  void ToonSequence()
  {
  }
  void resetMovie() 
  {
    captureFrameNum = 0;
  }
  void deleteFrame()
  {
    // the former frame goes to the garbage collector
    if (captureFrameNum > 0) 
    {
      captureFrameNum--;
    }
  }
  void addFrame() 
  {
    if (captureFrameNum < LOOP_MAX_NUM_FRAME) 
    {
      // We use new here, because it was not possible to overwrite an existing image.
      images[captureFrameNum] = new PImage(LOOP_WIDTH, LOOP_HEIGHT);
      images[captureFrameNum].copy(cam,0,0,LOOP_WIDTH,LOOP_HEIGHT, 0,0,LOOP_WIDTH,LOOP_HEIGHT);
      
      captureFrameNum++;
      isFlashing = 1;
    } 
    else {
      println("Reached max number of frames : " + LOOP_MAX_NUM_FRAME);
    }
  }
  void loopFrame() 
  {
    if (playFrameNum < captureFrameNum - 1) 
    {
      playFrameNum++;
    } else {
      playFrameNum = 0;
    }
  }
}

// UNCOMMENT If under GNU/Linux:
/*
void saveMovie() 
{
  println("Saving is disabled on GNU/Linux");
}
*/
// UNCOMMENT If under Mac or Windows:  
// Starts a thread to save a movie of the current sequence in the background.
void saveMovie() 
{
  SaveThread t = new SaveThread(this,currentSeq);
  t.start();  
}
// One thread to save a movie
class SaveThread extends Thread 
{
  PApplet theParent;
  int seqNum;
  // Args: PApplet "this", sequence number
  SaveThread(PApplet p, int sequenceNum) 
  {
    seqNum = sequenceNum;
    theParent = p;
    println("saving " + seqNum);
  }
  public void run() 
  {
    // Create MovieMaker object with size, filename,
    // compression codec and quality, framerate
    String file_name;
    if (sequences[seqNum].captureFrameNum == 0) 
    {
      println("no frame to save!");
    } 
    else 
    {
        file_name = "toonloop_"+String.valueOf(year())
            +"_"+String.valueOf(month())
            +"_"+String.valueOf(day())
                +"_"+String.valueOf(hour())
                +"h"+String.valueOf(minute())
                    +"m"+String.valueOf(second())
                    +".mov";
        println("saving to "+file_name+" :");
        is_displaying_saved_message = SAVED_MESSAGE_DURATION;
        saved_file_name = file_name;
        
        movieOut = new MovieMaker(theParent, LOOP_WIDTH, LOOP_HEIGHT, 
        file_name, FRAME_RATE, LOOP_CODEC, LOOP_QUALITY);
        for (int i = 0; i < sequences[seqNum].captureFrameNum; i++) 
        {
            print(i+" ");
            movieOut.addFrame(sequences[seqNum].images[i].pixels, LOOP_WIDTH, LOOP_HEIGHT);
        }
        println();
        movieOut.finish();
        println("done saving");
        movieOut = null;
    }
  }
}
// end of Mac or Windows
