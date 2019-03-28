import fisica.*;
import java.util.HashSet;
import processing.pdf.*;

boolean record;

ArrayList<Link> links = new ArrayList();
HashMap<String, FCircle> circles = new HashMap();
ArrayList<FCircle> circlesArray = new ArrayList();
FWorld world;


void setup(){
  size(720, 720);
  pixelDensity(displayDensity());
  background(255);
  
  String[] sub = loadStrings("subway.csv");
  println(sub.length); 
 
  HashSet<String> set = new HashSet();
  for( int i = 1; i < sub.length; i++){
    String line = sub[i];
    String[] parts = line.split(",");
    String startStation = parts[0];
    String stopStation = parts[1];
    String stationColor = parts[3];
    set.add(startStation);
    set.add(stopStation);
    color colorToStore = color(0); //creates the default color black
      if(stationColor.equals("red"))
      colorToStore = color(204, 0, 0);
      if(parts[3].equals("purple"))
      colorToStore = color(204, 0, 153);
       if(parts[3].equals("orange"))
      colorToStore = color(255, 102, 0);
       if(parts[3].equals("green"))
      colorToStore = color(0, 102, 0);
       if(parts[3].equals("brown"))
      colorToStore = color(153, 102, 51);
    Link link = new Link(startStation, stopStation, colorToStore);
    links.add(link);
  }
  
  Fisica.init(this);
  world = new FWorld();
  world.setGravity(0, 0);
  
  //initializes the nodes
  for(String name : set){
    FCircle circle = new FCircle(0.5);
    float posX = random(-200, 200);//smaller makes the start more compact
    float posY = random(-200, 200);
    circle.setPosition(posX, posY);
    circle.setName(name);
    circles.put(name, circle);
    circlesArray.add(circle);
    world.add(circle);
  
  }
  
  for(Link link : links){
    FCircle c1 = circles.get(link.a);
    FCircle c2 = circles.get(link.b);
    
    FDistanceJoint edge = new FDistanceJoint(c1, c2);
    edge.setLength(20);//larger makes final display very spread out
    edge.setFrequency(1);//lower slows it down
    edge.setStrokeColor(link.linkColor);
    world.add(edge);
    
  
  }
  
  println(set.size());
}

void draw(){
  if (record) {
    // Note that #### will be replaced with the frame number. Fancy!
    beginRecord(PDF, "frame-####.pdf"); 
  }
  
  background(255);
  
  for(int i = 0; i < circlesArray.size() - 1; i++){
    FCircle c1 = circlesArray.get(i);
    for(int j = i + 1; j < circlesArray.size(); j++){
      FCircle c2 = circlesArray.get(j);
      float d = dist(c1.getX(), c1.getY(), c2.getX(), c2.getY());
      float magnitude = 2/(d*d);
      //push c1 away from c2, c2 -> c1, c1 - c2
      float fx = c1.getX() - c2.getX();
      float fy = c1.getY() - c2.getY();
      fx = fx / d;
      fy = fy / d;
      fx = fx * magnitude;
      fy = fy * magnitude;
      c1.addForce(fx, fy);
      //push away c2 from c1
      c2.addForce(-fx, -fy);
    }
    float x = c1.getX();
    float y = c1.getY();
    fill(0);
    textSize(9);
    text(c1.getName(), x, y);
  }
  
  world.step();
  
  translate(width/2, height/2);
  world.draw();

  if (record) {
    endRecord();
  record = false;
  }

}

void mousePressed() {
  record = true;
}
