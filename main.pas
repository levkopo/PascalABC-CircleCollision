uses GraphABC;
uses Timers;

type
  Obj = class
  
  private
    r: integer;
    color: System.Drawing.Color;
    x: real = 0;
    y: real = 0;
    dy: real = 1;
    dx: real = 1;
  
  public
    constructor Create(initalX: real; initalY: real; objR: integer; c: System.Drawing.Color);
    begin
      x := initalX;
      y := initalY;
      r := objR;
      color := c;
    end;
    
    procedure update();
    begin
      x += dx;
      y += dy;
      
      if (round(x) + r >= WindowWidth) or (round(x) - r < 0) then
        dx := -dx;
      
      
      if (round(y) + r >= WindowHeight) or (round(y) - r < 0) then
        dy := -dy;
    end;
    
    procedure draw();
    begin
      SetPenColor(color);
      SetBrushColor(color);
      Circle(round(x), round(y), r);
    end;
  end;

var
  objs: array of Obj = Arr(
      new Obj(150, 150, 25, RGB(140, 90, 50)),
      new Obj(100, 50, 25, RGB(90, 50, 140)),
      new Obj(100, 200, 25, Color.Gold),
      new Obj(100, 250, 25, Color.Navy));

procedure updateObjs();
begin
    {$otp: pharallel for}
  for var i := 0 to objs.Length - 1 do
    objs[i].update();  
end;

begin
  var width: integer = 400;
  var height: integer = 400;
  SetWindowSize(width, height);
  SetSmoothing(true);
  
  var needFPS := 600;
  var frames := 0;
  var fps := needFPS;
  var startTime := Milliseconds;
  var endTime := startTime;
  var regressionTime := Milliseconds;
  var frameDrawStart := 0;
  
  {$otp: pharallel sections}
  begin
    //Update Thread
    begin
      var t := new Timer(floor(1), updateObjs);
      t.Start;
    end;
    
    //Render Thread
    begin
      while true do
      begin
        var d := endTime - startTime;
        if (d >= 1000) then
        begin
          fps := frames;
          frames := 0;
          
          regressionTime := Milliseconds - startTime - 1000;
          startTime := Milliseconds;
        end;
        
        
        SetPenColor(Color.White);
        SetBrushColor(Color.White);
        
        frameDrawStart := Milliseconds;
        LockDrawing;
        Rectangle(0, 0, WindowWidth, WindowHeight);
        
        TextOut(0, 15 * 0, 'FPS:' + fps);
        TextOut(0, 15 * 1, 'd Time:' + d);
        TextOut(0, 15 * 2, 'regressionTime Time:' + regressionTime);
        TextOut(0, 15 * 3, 'Frame:' + frames);
        TextOut(0, 15 * 5, 'endTime-frameDrawStart:' + (endTime - frameDrawStart));
        
        for var i := 0 to objs.Length - 1 do
          objs[i].draw();    
        
        Redraw;
        
        frames += 1;
        endTime := Milliseconds;
        
        var calculateWait: real = (d - regressionTime) / (needFPS);
        if calculateWait > 0 then Sleep(floor(calculateWait));
      end;
    end;
  end;
  
  
end.