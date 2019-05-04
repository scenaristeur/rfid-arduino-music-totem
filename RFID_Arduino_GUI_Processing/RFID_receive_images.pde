// animals http://soundbible.com/tags-animal.html
// animals https://www.freesoundeffects.com/free-sounds/animals-10013/
import java.util.Map;
import processing.serial.*;
//RFID
Serial myPort;  // Create object from Serial class
String dataReading = "";
String[] data;
String action = "";
String uid = "";

//MP3   librairie http://code.compartmental.net/minim/
import ddf.minim.*; 
AudioPlayer[] mplayer;
Minim minim;

HashMap<String, String> songs = new HashMap<String, String>();
HashMap<Integer, String> playing = new HashMap<Integer, String>();

int id_player = 0;
HashMap<Integer, PImage> images = new HashMap<Integer, PImage>();


void setup() 
{
 // size(1280, 1024);
  fullScreen();
  
  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');
  println(portName);

  minim = new Minim(this);
  mplayer=new AudioPlayer[8];


  // Putting key-value pairs in the HashMap
  songs.put("FA D7 41 09", "gibbon.mp3");
  songs.put("7B 20 92 15", "cow.mp3");
  songs.put("A3 46 18 1A", "labrador.mp3");
  songs.put("CB D8 BB 0C", "meadowlark.mp3");
}



void draw() {
  background(0);
  if ( myPort.available() > 0) {  // If data is available,
    //lecture 
    dataReading = myPort.readStringUntil('\n');
    if (dataReading != null && dataReading.length()>0) {
      println(dataReading);
      // Recuperation de l'action
      data = split(dataReading, ':');
      if (data.length == 3) {
        uid = trim(data[2]);
        if (data[0].equals("Reader 0")) {
          action = "START";
          id_player++;
          if (id_player > mplayer.length-1) {
            id_player = 0;
            //  mplayer[id_player].pause();
          }

          String mp3 = (String) songs.get(uid);

          if (mp3 != null) {
            if (mplayer[id_player]!= null) {
              mplayer[id_player].pause();
              mplayer[id_player].rewind();
            }
            mplayer[id_player] = minim.loadFile(mp3);
            mplayer[id_player].play();
            playing.put(id_player, uid);
            println("player "+id_player+" uid: "+uid+" song: "+mp3);
            //Image
            String nom_image = (String) split(songs.get(uid), ".")[0]+".jpg";
            println(nom_image);
            images.put(id_player, loadImage(nom_image));
          } else {
            println("aucun mp3 connu pour le tag"+uid);
          }
        } else if (data[0].equals("Reader 1")) {
          action = "STOP";

          for (Map.Entry p : playing.entrySet()) {
            Integer player = (Integer) p.getKey();
            String id = (String)p.getValue();
            if (uid.equals(id)) {
              println("pause "+player);
              mplayer[player].pause();
              playing.put(player, "");
              break; // exit for loop pour ne supprimer que le premier
            }
          }
        } else {
          println("commande INCONNUE "+data[0]);
        }
      }
      println(action+" "+uid);
      for (Map.Entry p : playing.entrySet()) {
        Integer player = (Integer) p.getKey();
        String id = (String)p.getValue();
        String song = songs.get(id);
        println("player : "+player+"\t\tid: "+id+"\t\t\tsong: "+song);
      }
      println("___________________________");
    }
  }
  display();
}

void display() {

  int largeur = (width-100)/mplayer.length;
  //println(caseLargeur);
  int x= 50, y = width/4, hauteur = largeur;
  for (int i = 0; i <mplayer.length; i++) {

    rect(x, y, largeur, hauteur);
    String id = playing.get(i);
    String song = songs.get(id);
    textSize(32);
    text("Animal "+i, x+10, y+30); 
    // fill(0, 102, 153);
    /*text("id carte "+id, x+10, y+60);
     fill(0, 102, 153, 51);*/
    if (song != null) {
      
       AudioPlayer p = mplayer[i];
      
      if (images.get(i) != null && p.position() < p.length()) {
        image(images.get(i), x, y, largeur, hauteur);
      }
      fill(0, 102, 153);
      textSize(12);
      text(song, x+10, y+60);
      //////////
     



      String couleur = intToARGB(song.hashCode());
      // println(couleur);
      //color col = "#"+couleur;
      int  y2 = y+i*largeur/2; //descendre les ondes

      for (int j = 0; j < p.bufferSize() - 1; j++)
      {
        line(j+x, y2+50  + p.left.get(j)*50, j+1+x, y2+50  + p.left.get(j+1)*50);
        line(j+x, y2+100 + p.right.get(j)*50, j+1+x, y2+100 + p.right.get(j+1)*50);
      }

      //stroke( 255, 0, 0 );
      stroke(unhex(couleur));
      float position = map( p.position(), 0, p.length(), 0, width );
      line( position, 0, position, height );




      ///////////
    }
    //text("id carte "+id, x+10, y+60);
    fill(0, 102, 153, 90);
    text("song "+song, x+10, y+90);


    x+=largeur;
    //println(x);
  }
}


String intToARGB(int i) {
  return Integer.toHexString(((i>>24)&0xFF))+
    Integer.toHexString(((i>>16)&0xFF))+
    Integer.toHexString(((i>>8)&0xFF))+
    "00"; // pas transparent
  //Integer.toHexString((i&0xFF));
}


/*
   for (int i=0; i<songs.length; i++) {
 mplayer[i] = minim.loadFile(songs[i]);
 // mplayer[i].play();
 }*/
// Using an enhanced loop to iterate over each entry
/*int i = 0;
 for (Map.Entry song : songs.entrySet()) {
 print(song.getKey() + " chargement ");
 println(song.getValue());
 String mp3 = (String) song.getValue();
 mplayer[i] = minim.loadFile(mp3);
 i++;
 }*/
