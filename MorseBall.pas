{$reference 'PresentationCore.dll'}
program MorseBall;

uses
  GraphABC, mouse_on_button, pop_up_window, game_process, timers;
const
  //colors
  background_color = clLightSteelBlue;
  active_color = RGB(217, 226, 157);
  highlighted_color = clAquamarine;
  deactive_color = clgray;
  letter_deactive_color = RGB(242, 226, 217);
  location_window_color = RGB(126, 189, 215);
  stats_color = RGB(192, 226, 217);
  color_1 = clblack;
  color_2 = clwhite;
  //coordinates
  center_x = windowwidth div 2;
  center_y = windowheight div 2;
  dx = windowwidth div 32;
  dy = windowheight div 32;
  dr = windowheight div 100 - 2;
  radius_x = 11 * windowwidth div 32;
  radius_y = 12 * windowheight div 32;

var
  t: timer;
  time: integer;
  //sounds
  sound: array[1..3] of system.Media.SoundPlayer;
  Player := new System.Windows.Media.MediaPlayer;
  //mouse
  mouse_x, mouse_y: integer;
  moving_mouse_x, moving_mouse_y: integer;  
  //processes
  public_process: string;//play,rules,shop,purchases
  local_process: string;//stories,themes
  page_process: string;//page1,page2,page3  
  //buttons
  size: array [1..18] of integer; //scale of buttons
  button_color: array[1..18] of color;//colors for buttons
  button_x: array[1..18]of integer;
  button_y: array[1..18]of integer;
  //menu
  angle_alpha: array[1..6] of real;//array for 6 angles of 6 buttons(play,rules,shop,options,exit)
  angle_alpha_delta: real;//for increasing alpha angle
  //shop
  button_availability: array[1..4, 13..18] of string;
  good_x, good_y: array[13..18] of integer;
  amount_of_money: integer;//amount of money
  //pictures of stories
  good_reading: string;
  pic: array [1..21] of picture;
  icon_pic: array [1..21] of picture;
  //pictures for options
  options_pic: array [1..6] of picture;
  options_str: array [1..6] of string;  
  //string
  global_str: array[1..47] of string;
  //stats
  stats_str: array[1..4] of integer;
  //icon of the app
  app_icon: picture;
  app_size: integer;
  //developer list
  dev_list: picture;
{--------------------------------------------------------procedures---------------------------------------------------------}
{--------------------------------------------------------------------------buttons------------------------------------------------------------------------}
//drawing menu buttons
procedure button_1(x, y, size: integer; text: string; button_color: color);
begin
  rectangle(x - 4 * dx - size - dr, y - 3 * dy - size - dr, x + 4 * dx + size + dr, y + 3 * dy + size + dr);
  setbrushcolor(button_color);
  fillrectangle(x - 4 * dx - size, y - 3 * dy - size, x + 4 * dx + size, y + 3 * dy + size);
  setbrushcolor(color_2);
  rectangle(x - 3 * dx - size, y - 2 * dy - size, x + 3 * dx + size, y + 2 * dy + size);
  setbrushstyle(bsclear);
  drawtextcentered(x - 3 * dx - size, y - 2 * dy - size, x + 3 * dx + size, y + 2 * dy + size, text);
  setbrushstyle(bssolid);
end;
//drawing main shop and page buttons
procedure button_2(x, y, size: integer; text: string; button_color: color);
begin
  rectangle(round(x - 4.5 * dx - size - dr), round(y - 1.5 * dy - size - dr), round(x + 4.5 * dx + size + dr), round(y + 1.5 * dy + size + dr));
  setbrushcolor(button_color);
  fillrectangle(round(x - 4.5 * dx - size), round(y - 1.5 * dy - size), round(x + 4.5 * dx + size), round(y + 1.5 * dy + size));
  setbrushcolor(color_2);
  rectangle(round(x - 3.5 * dx - size), round(y - 0.5 * dy - size), round(x + 3.5 * dx + size), round(y + 0.5 * dy + size));
  setbrushstyle(bsclear);
  drawtextcentered(round(x - 3.5 * dx - size), round(y - 0.5 * dy - size), round(x + 3.5 * dx + size), round(y + 0.5 * dy + size), text);
  setbrushstyle(bssolid);
end;
//drawing buy buttons
procedure button_3(x, y, size: integer; button_color: color; availability: string);
begin
  rectangle(round(x - 4 * dx - size - dr), round(y - 1 * dy - size - dr), round(x + 4 * dx + size + dr), round(y + 1 * dy + size + dr));
  setbrushcolor(button_color);
  fillrectangle(round(x - 4 * dx - size), round(y - 1 * dy - size), round(x + 4 * dx + size), round(y + 1 * dy + size));
  setbrushcolor(color_2);
  rectangle(round(x - 3 * dx - size), round(y - 0.5 * dy - size), round(x + 3 * dx + size), round(y + 0.5 * dy + size));
  setbrushstyle(bsclear);
  case public_process of 
    'shop': 
      begin
        if availability = 'available' then begin
          if local_process = 'stories' then drawtextcentered(round(x - 3.5 * dx - size), round(y - 0.5 * dy - size), round(x + 3.5 * dx + size), round(y + 0.5 * dy + size), global_str[18] + '  5');
          if local_process = 'themes' then drawtextcentered(round(x - 3.5 * dx - size), round(y - 0.5 * dy - size), round(x + 3.5 * dx + size), round(y + 0.5 * dy + size), global_str[18] + '  10');
        end;
        if (availability = 'unavailable') or (availability = 'using') then drawtextcentered(round(x - 3.5 * dx - size), round(y - 0.5 * dy - size), round(x + 3.5 * dx + size), round(y + 0.5 * dy + size), global_str[19]);
      end;
    'purchases': 
      begin
        case local_process of 
          'stories': 
            begin
              if availability = 'available' then drawtextcentered(round(x - 3.5 * dx - size), round(y - 0.5 * dy - size), round(x + 3.5 * dx + size), round(y + 0.5 * dy + size), global_str[22]);
              if availability = 'unavailable' then drawtextcentered(round(x - 3.5 * dx - size), round(y - 0.5 * dy - size), round(x + 3.5 * dx + size), round(y + 0.5 * dy + size), global_str[21]);                          
            end;
          'themes': 
            begin
              if availability = 'available' then drawtextcentered(round(x - 3.5 * dx - size), round(y - 0.5 * dy - size), round(x + 3.5 * dx + size), round(y + 0.5 * dy + size), global_str[22]);
              if availability = 'unavailable' then drawtextcentered(round(x - 3.5 * dx - size), round(y - 0.5 * dy - size), round(x + 3.5 * dx + size), round(y + 0.5 * dy + size), global_str[23]);
              if availability = 'using' then drawtextcentered(round(x - 3.5 * dx - size), round(y - 0.5 * dy - size), round(x + 3.5 * dx + size), round(y + 0.5 * dy + size), global_str[24]);
            end;        
        end;
      end;
  end;
  setbrushstyle(bssolid);
end;
//drawing upper window? that shows user his location in the game
procedure mid_window(str: string);
begin
  rectangle(center_x - 4 * dx - dr, center_y - 16 * dy - dr, center_x + 4 * dx + dr, center_y - 14 * dy + dr);
  setbrushcolor(location_window_color);
  rectangle(center_x - 4 * dx, center_y - 16 * dy, center_x + 4 * dx, center_y - 14 * dy);
  setbrushcolor(color_2);
  setbrushstyle(bsclear);
  drawtextcentered(center_x - 4 * dx, center_y - 16 * dy, center_x + 4 * dx, center_y - 14 * dy, str);
  setbrushstyle(bssolid);
end;

//drawing upper window, that shows user his location in the game
procedure left_window;
begin
  rectangle(center_x - 14 * dx - dr, center_y - 16 * dy - dr, center_x - 6 * dx + dr, center_y - 14 * dy + dr);
  setbrushcolor(location_window_color);
  rectangle(center_x - 14 * dx, center_y - 16 * dy, center_x - 6 * dx, center_y - 14 * dy);
  setbrushcolor(color_2);
  setbrushstyle(bsclear);
  if good_reading[3] = 'o' then begin
                                if length(good_reading)=7 then drawtextcentered(center_x - 14 * dx, center_y - 16 * dy, center_x - 6 * dx, center_y - 14 * dy, global_str[42] + ' ' + good_reading[length(good_reading)-1] + good_reading[length(good_reading)])
                                                          else drawtextcentered(center_x - 14 * dx, center_y - 16 * dy, center_x - 6 * dx, center_y - 14 * dy, global_str[42] + ' ' + good_reading[length(good_reading)]);
                                end;
  if good_reading[3] = 'a' then drawtextcentered(center_x - 14 * dx, center_y - 16 * dy, center_x - 6 * dx, center_y - 14 * dy, global_str[28]);
  setbrushstyle(bssolid);
end;
//drawing upper window that shows user his location in the game
procedure right_window(str: string);
begin
  if (public_process = 'purchases') and (good_reading <> '') then begin
  end
  else begin
    rectangle(center_x + 6 * dx - dr, center_y - 16 * dy - dr, center_x + 14 * dx + dr, center_y - 14 * dy + dr);
    setbrushcolor(location_window_color);
    rectangle(center_x + 6 * dx, center_y - 16 * dy, center_x + 14 * dx, center_y - 14 * dy);
    setbrushcolor(color_2);
    setbrushstyle(bsclear);
    drawtextcentered(center_x + 6 * dx, center_y - 16 * dy, center_x + 14 * dx, center_y - 14 * dy, str + ' ' + page_process[length(page_process)]);
    setbrushstyle(bssolid);
  end;
end;
//filling button with names of current language 
procedure fill_str;
var
  filetext, filetext1: text;
  language: string;
  i: integer;
begin
  assign(filetext, 'config\options.txt'); reset(filetext);
  readln(filetext);
  readln(filetext, language);
  if language = 'ENGLISH' then begin
    assign(filetext1, 'config\eng.txt'); reset(filetext1);
    for i := 1 to 47 do 
    begin
      readln(filetext1, global_str[i]);
    end;
    close(filetext1);                  
  end;
  if language = 'RUSSIAN' then begin
    assign(filetext1, 'config\rus.txt'); reset(filetext1);
    for i := 1 to 47 do 
    begin
      readln(filetext1, global_str[i]);
    end;
    close(filetext1);                  
  end;
  close(filetext);
end;
//getting mouse position from unit mouse_on_button
procedure onmouse;
begin
  //checking for pressing mouse
  onmousedown := position_of_mouse;
    //checking for moving mouse
  onmousemove := position_of_moving_mouse;
    {---------------------------------------------------------------}
    {equalation between unit and program valuse of mouse coordinates}
    {---------------------------------------------------------------}
  mouse_x := show_mouse_x;
  mouse_y := show_mouse_y;
  moving_mouse_x := show_moving_mouse_x;
  moving_mouse_y := show_moving_mouse_y;
end;
//music in the menu
procedure menu_music;
begin
  Player.Stop;
  Player.Open( new System.Uri('music\menu_music.mp3', System.UriKind.Relative));
  Player.Play;
end;
//dec timer
procedure dec_timer;
begin
  dec(time, 1);
end;
//checking if the music finished
procedure check_music;
begin
  if time = 0 then begin
    t.stop;
    time := 260;
    menu_music;
    t.start;
  end;
end;
//playing sound if the button pressed
procedure button_sound;
begin
  if options_str[1] = 'YES' then begin
    sound[1] := new system.Media.SoundPlayer;
    sound[1].SoundLocation := 'music\button_sound.wav';
    sound[1].Play;
  end;
end;
//playing sound if money are spent
procedure money_sound;
begin
  sound[2] := new system.Media.SoundPlayer;
  sound[2].SoundLocation := 'music\money_sound.wav';
  sound[2].Play;
end;
//playing sound if there is an impossible action
procedure error_sound;
begin
  sound[3] := new system.Media.SoundPlayer;
  sound[3].SoundLocation := 'music\error_sound.wav';
  sound[3].Play;
end;
//getting stats from the file
procedure get_stats;
var
  filetext: text;
  i: integer;
begin
  assign(filetext, 'config\stats.txt'); reset(filetext);
  for i := 1 to 4 do readln(filetext, stats_str[i]);
  close(filetext);
end;
//rewriting stats in the file
procedure rewrite_stats;
var
  filetext: text;
  i: integer;
begin
  assign(filetext, 'config\stats.txt'); rewrite(filetext);
  for i := 1 to 4 do writeln(filetext, stats_str[i]);
  close(filetext);
end;
//restore all stats
procedure restore_stats;
var
  filetext: text;
  i: integer;
begin
  assign(filetext, 'config\stats.txt'); rewrite(filetext);
  for i := 1 to 4 do 
  begin
    writeln(filetext, inttostr(0));
    stats_str[i] := 0;
  end;
  close(filetext);
end;
//getting options from the file
procedure get_options;
var
  filetext: text;
begin
  assign(filetext, 'config\options.txt');reset(filetext);
  readln(filetext, options_str[1]);
  readln(filetext, options_str[2]);
  readln(filetext, options_str[3]);
  readln(filetext, options_str[4]);
  readln(filetext, options_str[5]);
  readln(filetext, options_str[6]);
  close(filetext);
end;
//rewriting options in the file
procedure rewrite_options;
var
  filetext: text;
begin
  assign(filetext, 'config\options.txt');rewrite(filetext);
  writeln(filetext, options_str[1]);
  writeln(filetext, options_str[2]);
  writeln(filetext, options_str[3]);
  writeln(filetext, options_str[4]);
  writeln(filetext, options_str[5]);
  writeln(filetext, options_str[6]);
  close(filetext);
end;
//get money value
procedure get_money;
var
  filetext1: text;
begin
  assign(filetext1, 'config\amount_of_money.txt');reset(filetext1);
  readln(filetext1, amount_of_money);
  close(filetext1);
end;
//rewrite money value
procedure rewrite_money;
var
  filetext1: text;
begin
  assign(filetext1, 'config\amount_of_money.txt');rewrite(filetext1);
  writeln(filetext1, amount_of_money);
  close(filetext1);
end;
//rewrite file with the theme using right now
procedure rewrite_theme_using(str: string);
var
  filetext: text;
begin
  assign(filetext, 'config\theme_using.txt');rewrite(filetext);
  writeln(filetext, str);
  close(filetext);
end;
//icons of stories and themes
procedure pic_icon;
begin
  case public_process of 
    'shop', 'purchases': 
      begin
        case local_process of 
          'stories':
            begin
              case page_process of 
                'page1':
                  begin
                    icon_pic[1].Draw(good_x[13] - 4 * dx + 1, good_y[13] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2);
                    icon_pic[2].Draw(good_x[14] - 4 * dx + 1, good_y[14] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2);
                    icon_pic[3].Draw(good_x[15] - 4 * dx + 1, good_y[15] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2);
                    icon_pic[4].Draw(good_x[16] - 4 * dx + 1, good_y[16] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2);
                    icon_pic[5].Draw(good_x[17] - 4 * dx + 1, good_y[17] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2);
                    icon_pic[6].Draw(good_x[18] - 4 * dx + 1, good_y[18] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2);
                  end;
                'page2':
                  begin
                    icon_pic[7].Draw(good_x[13] - 4 * dx + 1, good_y[13] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2);
                    icon_pic[8].Draw(good_x[14] - 4 * dx + 1, good_y[14] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2);
                    icon_pic[9].Draw(good_x[15] - 4 * dx + 1, good_y[15] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2);
                    icon_pic[10].Draw(good_x[16] - 4 * dx + 1, good_y[16] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2);
                    icon_pic[11].Draw(good_x[17] - 4 * dx + 1, good_y[17] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2);
                    icon_pic[12].Draw(good_x[18] - 4 * dx + 1, good_y[18] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2);
                  end;
                'page3':
                  begin
                    icon_pic[13].Draw(good_x[13] - 4 * dx + 1, good_y[13] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2);
                    icon_pic[14].Draw(good_x[14] - 4 * dx + 1, good_y[14] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2);
                    icon_pic[15].Draw(good_x[15] - 4 * dx + 1, good_y[15] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2);
                    icon_pic[16].Draw(good_x[16] - 4 * dx + 1, good_y[16] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2);
                    icon_pic[17].Draw(good_x[17] - 4 * dx + 1, good_y[17] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2);
                    icon_pic[18].Draw(good_x[18] - 4 * dx + 1, good_y[18] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2);
                  end;
              end;
            end;
          'themes':
            begin
              icon_pic[19].Draw(good_x[13] - 4 * dx + 1, good_y[13] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2); 
              icon_pic[20].Draw(good_x[14] - 4 * dx + 1, good_y[14] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2); 
              icon_pic[21].Draw(good_x[15] - 4 * dx + 1, good_y[15] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2); 
            end;
        end;
      end;
    'options':
      begin
        options_pic[1].Draw(good_x[13] - 4 * dx + 1, good_y[13] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2);
        options_pic[2].Draw(good_x[14] - 4 * dx + 1, good_y[14] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2);
        options_pic[3].Draw(good_x[15] - 4 * dx + 1, good_y[15] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2);
        options_pic[4].Draw(good_x[16] - 4 * dx + 1, good_y[16] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2);
        options_pic[5].Draw(good_x[17] - 4 * dx + 1, good_y[17] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2);
        options_pic[6].Draw(good_x[18] - 4 * dx + 1, good_y[18] - 3 * dy + 1, 8 * dx - 2, 6 * dy - 2);
      end;
  end;
end;
//drawing rules and reading stories process
procedure pic_big;
begin
  case public_process of 
    'rules':
      begin
        rectangle(center_x - 14 * dx, center_y - 13 * dy, center_x + 14 * dx, center_y + 6 * dy);
        rectangle(center_x - 14 * dx + dr, center_y - 13 * dy + dr, center_x + 14 * dx - dr, center_y + 6 * dy - dr);
        case page_process of
          'page1':  pic[19].Draw(center_x - 14 * dx + dr + 1, center_y - 13 * dy + dr + 1, 28 * dx - 2 * dr - 2, 19 * dy - 2 * dr - 2);
          'page2':  pic[20].Draw(center_x - 14 * dx + dr + 1, center_y - 13 * dy + dr + 1, 28 * dx - 2 * dr - 2, 19 * dy - 2 * dr - 2);
          'page3':  pic[21].Draw(center_x - 14 * dx + dr + 1, center_y - 13 * dy + dr + 1, 28 * dx - 2 * dr - 2, 19 * dy - 2 * dr - 2);
        end;
      end;
    'purchases':
      begin
        case page_process of 
          'page1': 
            begin
              if good_reading = 'story1' then begin
                rectangle(center_x - 14 * dx, center_y - 13 * dy, center_x + 14 * dx, center_y + 10 * dy);
                rectangle(center_x - 14 * dx + dr, center_y - 13 * dy + dr, center_x + 14 * dx - dr, center_y + 10 * dy - dr);
                pic[1].Draw(center_x - 14 * dx + dr + 1, center_y - 13 * dy + dr + 1, 28 * dx - 2 * dr - 2, 23 * dy - 2 * dr - 2);
              end;
              if good_reading = 'story2' then begin
                rectangle(center_x - 14 * dx, center_y - 13 * dy, center_x + 14 * dx, center_y + 10 * dy);
                rectangle(center_x - 14 * dx + dr, center_y - 13 * dy + dr, center_x + 14 * dx - dr, center_y + 10 * dy - dr);
                pic[2].Draw(center_x - 14 * dx + dr + 1, center_y - 13 * dy + dr + 1, 28 * dx - 2 * dr - 2, 23 * dy - 2 * dr - 2);
              end;
              if good_reading = 'story3' then begin
                rectangle(center_x - 14 * dx, center_y - 13 * dy, center_x + 14 * dx, center_y + 10 * dy);
                rectangle(center_x - 14 * dx + dr, center_y - 13 * dy + dr, center_x + 14 * dx - dr, center_y + 10 * dy - dr);
                pic[3].Draw(center_x - 14 * dx + dr + 1, center_y - 13 * dy + dr + 1, 28 * dx - 2 * dr - 2, 23 * dy - 2 * dr - 2);
              end;
              if good_reading = 'story4' then begin
                rectangle(center_x - 14 * dx, center_y - 13 * dy, center_x + 14 * dx, center_y + 10 * dy);
                rectangle(center_x - 14 * dx + dr, center_y - 13 * dy + dr, center_x + 14 * dx - dr, center_y + 10 * dy - dr);
                pic[4].Draw(center_x - 14 * dx + dr + 1, center_y - 13 * dy + dr + 1, 28 * dx - 2 * dr - 2, 23 * dy - 2 * dr - 2);
              end;
              if good_reading = 'story5' then begin
                rectangle(center_x - 14 * dx, center_y - 13 * dy, center_x + 14 * dx, center_y + 10 * dy);
                rectangle(center_x - 14 * dx + dr, center_y - 13 * dy + dr, center_x + 14 * dx - dr, center_y + 10 * dy - dr);
                pic[5].Draw(center_x - 14 * dx + dr + 1, center_y - 13 * dy + dr + 1, 28 * dx - 2 * dr - 2, 23 * dy - 2 * dr - 2);
              end;
              if good_reading = 'story6' then begin
                rectangle(center_x - 14 * dx, center_y - 13 * dy, center_x + 14 * dx, center_y + 10 * dy);
                rectangle(center_x - 14 * dx + dr, center_y - 13 * dy + dr, center_x + 14 * dx - dr, center_y + 10 * dy - dr);
                pic[6].Draw(center_x - 14 * dx + dr + 1, center_y - 13 * dy + dr + 1, 28 * dx - 2 * dr - 2, 23 * dy - 2 * dr - 2);
              end;
            end;
          'page2': 
            begin
              if good_reading = 'story7' then begin
                rectangle(center_x - 14 * dx, center_y - 13 * dy, center_x + 14 * dx, center_y + 10 * dy);
                rectangle(center_x - 14 * dx + dr, center_y - 13 * dy + dr, center_x + 14 * dx - dr, center_y + 10 * dy - dr);
                pic[7].Draw(center_x - 14 * dx + dr + 1, center_y - 13 * dy + dr + 1, 28 * dx - 2 * dr - 2, 23 * dy - 2 * dr - 2);
              end;
              if good_reading = 'story8' then begin
                rectangle(center_x - 14 * dx, center_y - 13 * dy, center_x + 14 * dx, center_y + 10 * dy);
                rectangle(center_x - 14 * dx + dr, center_y - 13 * dy + dr, center_x + 14 * dx - dr, center_y + 10 * dy - dr);
                pic[8].Draw(center_x - 14 * dx + dr + 1, center_y - 13 * dy + dr + 1, 28 * dx - 2 * dr - 2, 23 * dy - 2 * dr - 2);
              end;
              if good_reading = 'story9' then begin
                rectangle(center_x - 14 * dx, center_y - 13 * dy, center_x + 14 * dx, center_y + 10 * dy);
                rectangle(center_x - 14 * dx + dr, center_y - 13 * dy + dr, center_x + 14 * dx - dr, center_y + 10 * dy - dr);
                pic[9].Draw(center_x - 14 * dx + dr + 1, center_y - 13 * dy + dr + 1, 28 * dx - 2 * dr - 2, 23 * dy - 2 * dr - 2);
              end;
              if good_reading = 'story10' then begin
                rectangle(center_x - 14 * dx, center_y - 13 * dy, center_x + 14 * dx, center_y + 10 * dy);
                rectangle(center_x - 14 * dx + dr, center_y - 13 * dy + dr, center_x + 14 * dx - dr, center_y + 10 * dy - dr);
                pic[10].Draw(center_x - 14 * dx + dr + 1, center_y - 13 * dy + dr + 1, 28 * dx - 2 * dr - 2, 23 * dy - 2 * dr - 2);
              end;
              if good_reading = 'story11' then begin
                rectangle(center_x - 14 * dx, center_y - 13 * dy, center_x + 14 * dx, center_y + 10 * dy);
                rectangle(center_x - 14 * dx + dr, center_y - 13 * dy + dr, center_x + 14 * dx - dr, center_y + 10 * dy - dr);
                pic[11].Draw(center_x - 14 * dx + dr + 1, center_y - 13 * dy + dr + 1, 28 * dx - 2 * dr - 2, 23 * dy - 2 * dr - 2);
              end;
              if good_reading = 'story12' then begin
                rectangle(center_x - 14 * dx, center_y - 13 * dy, center_x + 14 * dx, center_y + 10 * dy);
                rectangle(center_x - 14 * dx + dr, center_y - 13 * dy + dr, center_x + 14 * dx - dr, center_y + 10 * dy - dr);
                pic[12].Draw(center_x - 14 * dx + dr + 1, center_y - 13 * dy + dr + 1, 28 * dx - 2 * dr - 2, 23 * dy - 2 * dr - 2);
              end;
            end;
          'page3': 
            begin
              if good_reading = 'story13' then begin
                rectangle(center_x - 14 * dx, center_y - 13 * dy, center_x + 14 * dx, center_y + 10 * dy);
                rectangle(center_x - 14 * dx + dr, center_y - 13 * dy + dr, center_x + 14 * dx - dr, center_y + 10 * dy - dr);
                pic[13].Draw(center_x - 14 * dx + dr + 1, center_y - 13 * dy + dr + 1, 28 * dx - 2 * dr - 2, 23 * dy - 2 * dr - 2);
              end;
              if good_reading = 'story14' then begin
                rectangle(center_x - 14 * dx, center_y - 13 * dy, center_x + 14 * dx, center_y + 10 * dy);
                rectangle(center_x - 14 * dx + dr, center_y - 13 * dy + dr, center_x + 14 * dx - dr, center_y + 10 * dy - dr);
                pic[14].Draw(center_x - 14 * dx + dr + 1, center_y - 13 * dy + dr + 1, 28 * dx - 2 * dr - 2, 23 * dy - 2 * dr - 2);
              end;
              if good_reading = 'story15' then begin
                rectangle(center_x - 14 * dx, center_y - 13 * dy, center_x + 14 * dx, center_y + 10 * dy);
                rectangle(center_x - 14 * dx + dr, center_y - 13 * dy + dr, center_x + 14 * dx - dr, center_y + 10 * dy - dr);
                pic[15].Draw(center_x - 14 * dx + dr + 1, center_y - 13 * dy + dr + 1, 28 * dx - 2 * dr - 2, 23 * dy - 2 * dr - 2);
              end;
              if good_reading = 'story16' then begin
                rectangle(center_x - 14 * dx, center_y - 13 * dy, center_x + 14 * dx, center_y + 10 * dy);
                rectangle(center_x - 14 * dx + dr, center_y - 13 * dy + dr, center_x + 14 * dx - dr, center_y + 10 * dy - dr);
                pic[16].Draw(center_x - 14 * dx + dr + 1, center_y - 13 * dy + dr + 1, 28 * dx - 2 * dr - 2, 23 * dy - 2 * dr - 2);
              end;
              if good_reading = 'story17' then begin
                rectangle(center_x - 14 * dx, center_y - 13 * dy, center_x + 14 * dx, center_y + 10 * dy);
                rectangle(center_x - 14 * dx + dr, center_y - 13 * dy + dr, center_x + 14 * dx - dr, center_y + 10 * dy - dr);
                pic[17].Draw(center_x - 14 * dx + dr + 1, center_y - 13 * dy + dr + 1, 28 * dx - 2 * dr - 2, 23 * dy - 2 * dr - 2);
              end;
              if good_reading = 'story18' then begin
                rectangle(center_x - 14 * dx, center_y - 13 * dy, center_x + 14 * dx, center_y + 10 * dy);
                rectangle(center_x - 14 * dx + dr, center_y - 13 * dy + dr, center_x + 14 * dx - dr, center_y + 10 * dy - dr);
                pic[18].Draw(center_x - 14 * dx + dr + 1, center_y - 13 * dy + dr + 1, 28 * dx - 2 * dr - 2, 23 * dy - 2 * dr - 2);
              end;
            end;
        end;  
      end;
    'options':
      begin
        get_stats;
        if good_reading = 'stats' then begin
          rectangle(center_x - 14 * dx, center_y - 13 * dy, center_x + 14 * dx, center_y + 10 * dy);
          rectangle(center_x - 14 * dx + dr, center_y - 13 * dy + dr, center_x + 14 * dx - dr, center_y + 10 * dy - dr);
          setbrushcolor(color_2);
          rectangle(center_x - 14 * dx + dr, round(center_y - 13 * dy) + dr, center_x + 14 * dx - dr, round(center_y - 7.25 * dy) + 1);
          drawtextcentered(center_x - 14 * dx, round(center_y - 13 * dy), center_x + 14 * dx, round(center_y - 7.25 * dy), global_str[36] + ' ' + stats_str[1] + '/21');
          line(center_x - 14 * dx + dr, round(center_y - 7.25 * dy), center_x + 14 * dx - dr, round(center_y - 7.25 * dy));
          setbrushcolor(stats_color);
          rectangle(center_x - 14 * dx + dr, round(center_y - 7.25 * dy), center_x + 14 * dx - dr, round(center_y - 1.5 * dy) + 1);
          drawtextcentered(center_x - 14 * dx, round(center_y - 7.25 * dy), center_x + 14 * dx, round(center_y - 1.5 * dy), global_str[37] + ' ' + stats_str[2]);
          line(center_x - 14 * dx + dr, round(center_y - 1.5 * dy), center_x + 14 * dx - dr, round(center_y - 1.5 * dy));
          setbrushcolor(color_2);
          rectangle(center_x - 14 * dx + dr, round(center_y - 1.5 * dy), center_x + 14 * dx - dr, round(center_y + 4.25 * dy) + 1);
          drawtextcentered(center_x - 14 * dx, round(center_y - 1.5 * dy), center_x + 14 * dx, round(center_y + 4.25 * dy), global_str[38] + ' ' + stats_str[3]);
          line(center_x - 14 * dx + dr, round(center_y + 4.25 * dy), center_x + 14 * dx - dr, round(center_y + 4.25 * dy));
          setbrushcolor(stats_color);
          rectangle(center_x - 14 * dx + dr, round(center_y + 4.25 * dy), center_x + 14 * dx - dr, round(center_y + 10 * dy) - dr + 1);
          drawtextcentered(center_x - 14 * dx, round(center_y + 4.25 * dy), center_x + 14 * dx, round(center_y + 10 * dy), global_str[39] + ' ' + stats_str[4]);
          setbrushcolor(color_2);
          button_2(button_x[8], button_y[8], size[8], global_str[20], button_color[8]);
        end;
      end;
    'developers': 
      begin
        rectangle(center_x - 14 * dx, center_y - 13 * dy, center_x + 14 * dx, center_y + 10 * dy);
        rectangle(center_x - 14 * dx + dr, center_y - 13 * dy + dr, center_x + 14 * dx - dr, center_y + 10 * dy - dr);
        dev_list.Draw(center_x - 14 * dx + dr + 1, center_y - 13 * dy + dr + 1, 28 * dx - 2 * dr - 2, 23 * dy - 2 * dr - 2);
      end;
  end;
end;
//initialization
procedure initialize;
var
  filetext, filetext1: text;
  i: integer;
begin
  //buttons
  button_x[1] := 0;
  button_x[2] := 0;
  button_x[3] := 0;
  button_x[4] := 0;
  button_x[5] := 0;
  button_x[6] := 0;
  button_x[7] := center_x - 10 * dx;
  button_x[8] := center_x;
  button_x[9] := center_x + 10 * dx;
  button_x[10] := center_x - 10 * dx;
  button_x[11] := center_x;
  button_x[12] := center_x + 10 * dx;
  button_x[13] := center_x - 10 * dx;
  button_x[14] := center_x;
  button_x[15] := center_x + 10 * dx;
  button_x[16] := center_x - 10 * dx;
  button_x[17] := center_x;
  button_x[18] := center_x + 10 * dx;
  button_y[1] := 0;
  button_y[2] := 0;
  button_y[3] := 0;
  button_y[4] := 0;
  button_y[5] := 0;
  button_y[6] := 0;
  button_y[7] := round(center_y + 12.5 * dy);
  button_y[8] := round(center_y + 12.5 * dy);
  button_y[9] := round(center_y + 12.5 * dy);
  button_y[10] := round(center_y + 8.5 * dy);
  button_y[11] := round(center_y + 8.5 * dy);
  button_y[12] := round(center_y + 8.5 * dy);
  button_y[13] := center_y - 5 * dy;
  button_y[14] := center_y - 5 * dy;
  button_y[15] := center_y - 5 * dy;
  button_y[16] := center_y + 5 * dy;
  button_y[17] := center_y + 5 * dy;
  button_y[18] := center_y + 5 * dy;
  //goods
  good_x[13] := center_x - 10 * dx;
  good_x[14] := center_x;
  good_x[15] := center_x + 10 * dx;
  good_x[16] := center_x - 10 * dx;
  good_x[17] := center_x;
  good_x[18] := center_x + 10 * dx;
  good_y[13] := center_y - 10 * dy;
  good_y[14] := center_y - 10 * dy;
  good_y[15] := center_y - 10 * dy;
  good_y[16] := center_y;
  good_y[17] := center_y;
  good_y[18] := center_y;
  //shop button availability
  assign(filetext, 'config\button_availability.txt'); reset(filetext);
  for i := 13 to 18 do readln(filetext, button_availability[1, i]);
  for i := 13 to 18 do readln(filetext, button_availability[2, i]);  
  for i := 13 to 18 do readln(filetext, button_availability[3, i]);
  for i := 13 to 15 do readln(filetext, button_availability[4, i]);      
  close(filetext);
  //money
  assign(filetext1, 'config\amount_of_money.txt');reset(filetext1);
  readln(filetext1, amount_of_money);
  close(filetext1);
  //app icon
  app_icon := picture.Create('pictures\morseball.png');
  //options
  get_options;
  get_stats;
end;

procedure initialize_pictures;
begin
  if options_str[2] = 'ENGLISH' then begin
    //pictures
    icon_pic[1] := picture.Create('pictures\eng\icons\stories\story1.png');
    icon_pic[2] := picture.Create('pictures\eng\icons\stories\story2.png');
    icon_pic[3] := picture.Create('pictures\eng\icons\stories\story3.png');
    icon_pic[4] := picture.Create('pictures\eng\icons\stories\story4.png');
    icon_pic[5] := picture.Create('pictures\eng\icons\stories\story5.png');
    icon_pic[6] := picture.Create('pictures\eng\icons\stories\story6.png');
    icon_pic[7] := picture.Create('pictures\eng\icons\stories\story7.png');
    icon_pic[8] := picture.Create('pictures\eng\icons\stories\story8.png');
    icon_pic[9] := picture.Create('pictures\eng\icons\stories\story9.png');
    icon_pic[10] := picture.Create('pictures\eng\icons\stories\story10.png');
    icon_pic[11] := picture.Create('pictures\eng\icons\stories\story11.png');
    icon_pic[12] := picture.Create('pictures\eng\icons\stories\story12.png');
    icon_pic[13] := picture.Create('pictures\eng\icons\stories\story13.png');
    icon_pic[14] := picture.Create('pictures\eng\icons\stories\story14.png');
    icon_pic[15] := picture.Create('pictures\eng\icons\stories\story15.png');
    icon_pic[16] := picture.Create('pictures\eng\icons\stories\story16.png');
    icon_pic[17] := picture.Create('pictures\eng\icons\stories\story17.png');
    icon_pic[18] := picture.Create('pictures\eng\icons\stories\story18.png');
    icon_pic[19] := picture.Create('pictures\eng\icons\themes\theme1.png');
    icon_pic[20] := picture.Create('pictures\eng\icons\themes\theme2.png');
    icon_pic[21] := picture.Create('pictures\eng\icons\themes\theme3.png');
    pic[1] := picture.Create('pictures\eng\stories\story1.png');
    pic[2] := picture.Create('pictures\eng\stories\story2.png');
    pic[3] := picture.Create('pictures\eng\stories\story3.png');
    pic[4] := picture.Create('pictures\eng\stories\story4.png');
    pic[5] := picture.Create('pictures\eng\stories\story5.png');
    pic[6] := picture.Create('pictures\eng\stories\story6.png');
    pic[7] := picture.Create('pictures\eng\stories\story7.png');
    pic[8] := picture.Create('pictures\eng\stories\story8.png');
    pic[9] := picture.Create('pictures\eng\stories\story9.png');
    pic[10] := picture.Create('pictures\eng\stories\story10.png');
    pic[11] := picture.Create('pictures\eng\stories\story11.png');
    pic[12] := picture.Create('pictures\eng\stories\story12.png');
    pic[13] := picture.Create('pictures\eng\stories\story13.png');
    pic[14] := picture.Create('pictures\eng\stories\story14.png');
    pic[15] := picture.Create('pictures\eng\stories\story15.png');
    pic[16] := picture.Create('pictures\eng\stories\story16.png');
    pic[17] := picture.Create('pictures\eng\stories\story17.png');
    pic[18] := picture.Create('pictures\eng\stories\story18.png');
    pic[19] := picture.Create('pictures\eng\rules\rule1.png');
    pic[20] := picture.Create('pictures\eng\rules\rule2.png');
    pic[21] := picture.Create('pictures\eng\rules\rule3.png');
    options_pic[1] := picture.Create('pictures\eng\icons\options\sound.png');
    options_pic[2] := picture.Create('pictures\eng\icons\options\language.png');
    options_pic[3] := picture.Create('pictures\eng\icons\options\animation.png');
    options_pic[4] := picture.Create('pictures\eng\icons\options\stats.png');
    options_pic[5] := picture.Create('pictures\eng\icons\options\wind.png');
    options_pic[6] := picture.Create('pictures\eng\icons\options\trajectory.png');
    dev_list := picture.Create('pictures\eng\developers\thanks.png');
  end;
  
  if options_str[2] = 'RUSSIAN' then begin
    //pictures
    icon_pic[1] := picture.Create('pictures\rus\icons\stories\story1.png');
    icon_pic[2] := picture.Create('pictures\rus\icons\stories\story2.png');
    icon_pic[3] := picture.Create('pictures\rus\icons\stories\story3.png');
    icon_pic[4] := picture.Create('pictures\rus\icons\stories\story4.png');
    icon_pic[5] := picture.Create('pictures\rus\icons\stories\story5.png');
    icon_pic[6] := picture.Create('pictures\rus\icons\stories\story6.png');
    icon_pic[7] := picture.Create('pictures\rus\icons\stories\story7.png');
    icon_pic[8] := picture.Create('pictures\rus\icons\stories\story8.png');
    icon_pic[9] := picture.Create('pictures\rus\icons\stories\story9.png');
    icon_pic[10] := picture.Create('pictures\rus\icons\stories\story10.png');
    icon_pic[11] := picture.Create('pictures\rus\icons\stories\story11.png');
    icon_pic[12] := picture.Create('pictures\rus\icons\stories\story12.png');
    icon_pic[13] := picture.Create('pictures\rus\icons\stories\story13.png');
    icon_pic[14] := picture.Create('pictures\rus\icons\stories\story14.png');
    icon_pic[15] := picture.Create('pictures\rus\icons\stories\story15.png');
    icon_pic[16] := picture.Create('pictures\rus\icons\stories\story16.png');
    icon_pic[17] := picture.Create('pictures\rus\icons\stories\story17.png');
    icon_pic[18] := picture.Create('pictures\rus\icons\stories\story18.png');
    icon_pic[19] := picture.Create('pictures\rus\icons\themes\theme1.png');
    icon_pic[20] := picture.Create('pictures\rus\icons\themes\theme2.png');
    icon_pic[21] := picture.Create('pictures\rus\icons\themes\theme3.png');
    pic[1] := picture.Create('pictures\rus\stories\story1.png');
    pic[2] := picture.Create('pictures\rus\stories\story2.png');
    pic[3] := picture.Create('pictures\rus\stories\story3.png');
    pic[4] := picture.Create('pictures\rus\stories\story4.png');
    pic[5] := picture.Create('pictures\rus\stories\story5.png');
    pic[6] := picture.Create('pictures\rus\stories\story6.png');
    pic[7] := picture.Create('pictures\rus\stories\story7.png');
    pic[8] := picture.Create('pictures\rus\stories\story8.png');
    pic[9] := picture.Create('pictures\rus\stories\story9.png');
    pic[10] := picture.Create('pictures\rus\stories\story10.png');
    pic[11] := picture.Create('pictures\rus\stories\story11.png');
    pic[12] := picture.Create('pictures\rus\stories\story12.png');
    pic[13] := picture.Create('pictures\rus\stories\story13.png');
    pic[14] := picture.Create('pictures\rus\stories\story14.png');
    pic[15] := picture.Create('pictures\rus\stories\story15.png');
    pic[16] := picture.Create('pictures\rus\stories\story16.png');
    pic[17] := picture.Create('pictures\rus\stories\story17.png');
    pic[18] := picture.Create('pictures\rus\stories\story18.png');
    pic[19] := picture.Create('pictures\rus\rules\rule1.png');
    pic[20] := picture.Create('pictures\rus\rules\rule2.png');
    pic[21] := picture.Create('pictures\rus\rules\rule3.png');
    options_pic[1] := picture.Create('pictures\rus\icons\options\sound.png');
    options_pic[2] := picture.Create('pictures\rus\icons\options\language.png');
    options_pic[3] := picture.Create('pictures\rus\icons\options\animation.png');
    options_pic[4] := picture.Create('pictures\rus\icons\options\stats.png');
    options_pic[5] := picture.Create('pictures\rus\icons\options\wind.png');
    options_pic[6] := picture.Create('pictures\rus\icons\options\trajectory.png');
    dev_list := picture.Create('pictures\rus\developers\thanks.png');
  end;
end;

//read the file button_availability.txt for available or unavailable or using right now goods
procedure get_button_availability(localprocess, pageprocess: string);
var
  filetext: text;
  i: integer;
begin
  assign(filetext, 'config\button_availability.txt'); reset(filetext);
  for i := 13 to 18 do readln(filetext, button_availability[1, i]);
  for i := 13 to 18 do readln(filetext, button_availability[2, i]);
  for i := 13 to 18 do readln(filetext, button_availability[3, i]);
  for i := 13 to 15 do readln(filetext, button_availability[4, i]);           
  close(filetext);
end;
//rewrite the file button_availability.txt with available or unavailable or using right now goods
procedure rewrite_button_availability;
var
  filetext: text;
  i: integer;
begin
  assign(filetext, 'config\button_availability.txt'); rewrite(filetext);
  for i := 13 to 18 do writeln(filetext, button_availability[1, i]);
  for i := 13 to 18 do writeln(filetext, button_availability[2, i]);  
  for i := 13 to 18 do writeln(filetext, button_availability[3, i]); 
  for i := 13 to 15 do writeln(filetext, button_availability[4, i]);      
  close(filetext);
end;
//restore all purchases 
procedure restore_purchases;
var
  filetext: text;
  i: integer;
begin
  assign(filetext, 'config\button_availability.txt'); rewrite(filetext);
  for i := 13 to 18 do writeln(filetext, 'available');
  for i := 13 to 18 do writeln(filetext, 'available');  
  for i := 13 to 18 do writeln(filetext, 'available');
  for i := 13 to 15 do writeln(filetext, 'available');
  for i := 13 to 18 do button_availability[1, i] := 'available';
  for i := 13 to 18 do button_availability[2, i] := 'available'; 
  for i := 13 to 18 do button_availability[3, i] := 'available';
  for i := 13 to 15 do button_availability[4, i] := 'available';
  close(filetext);
  rewrite_theme_using('default');
end;
//checking for pressed or moved button;
procedure check_button;
var
  i: integer;
begin
  case public_process of 
    'menu': 
      begin
        for i := 1 to 6 do 
        begin
          if (moving_mouse_x > button_x[i] - 4 * dx - size[i] - dr) and (moving_mouse_x < button_x[i] + 4 * dx + size[i] + dr) and (moving_mouse_y > button_y[i] - 3 * dy - size[i] - dr) and (moving_mouse_y < button_y[i] + 3 * dy + size[i] + dr) then begin
            if size[i] <> 6 then inc(size[i], 2);
            button_color[i] := highlighted_color;
          end
          else begin
            if size[i] <> 0 then dec(size[i], 2);
            button_color[i] := deactive_color;
          end;
          if (mouse_x > button_x[i] - 4 * dx - size[i] - dr) and (mouse_x < button_x[i] + 4 * dx + size[i] + dr) and (mouse_y > button_y[i] - 3 * dy - size[i] - dr) and (mouse_y < button_y[i] + 3 * dy + size[i] + dr) then begin
            button_sound;
            clear_mouse_xy;
            case i of
              1: public_process := 'mode_choose';
              2: public_process := 'rules';
              3: public_process := 'shop';
              4: public_process := 'purchases';
              5: public_process := 'options';
              6: closewindow;
            end;
            mouse_x := 0;
            mouse_y := 0;
          end;
        end;
        //opening developers list
        if (mouse_x < center_x + 4 * dx + app_size + dr) and (mouse_x > center_x - 4 * dx - app_size - dr) and (mouse_y < center_y + 2 * dy + app_size + dr) and (mouse_y > center_y - 2 * dy - app_size - dr) then begin
          button_sound;
          public_process := 'developers';
        end;
        if (moving_mouse_x < center_x + 4 * dx + app_size + dr) and (moving_mouse_x > center_x - 4 * dx - app_size - dr) and (moving_mouse_y < center_y + 2 * dy + app_size + dr) and (moving_mouse_y > center_y - 2 * dy - app_size - dr) then begin
          if app_size <> 10 then inc(app_size, 2);
        end
        else begin
          if app_size <> 0 then dec(app_size, 2);
        end;
      end;
    'rules': 
      begin
        for i := 9 to 12 do 
        begin
          if (moving_mouse_x > round(button_x[i] - 4.5 * dx - size[i] - dr)) and (moving_mouse_x < round(button_x[i] + 4.5 * dx + size[i] + dr)) and (moving_mouse_y > round(button_y[i] - 1.5 * dy - size[i] - dr)) and (moving_mouse_y < round(button_y[i] + 1.5 * dy + size[i] + dr)) then begin
            if size[i] <> 6 then inc(size[i], 2);                                                                                                                                                                                                                                                              
            if button_color[i] <> active_color then button_color[i] := highlighted_color;
          end
          else begin
            if size[i] <> 0 then dec(size[i], 2);
            if button_color[i] <> active_color then button_color[i] := deactive_color;
          end;
          if (mouse_x > round(button_x[i] - 4.5 * dx - size[i] - dr)) and (mouse_x < round(button_x[i] + 4.5 * dx + size[i] + dr)) and (mouse_y > round(button_y[i] - 1.5 * dy - size[i] - dr)) and (mouse_y < round(button_y[i] + 1.5 * dy + size[i] + dr)) then begin
            case i of
              9: 
                begin
                  button_sound;
                  public_process := 'menu';
                end;
              10:
                begin
                  if page_process = 'page2' then begin
                    button_sound;
                    page_process := 'page1';
                    continue;
                  end;
                  if page_process = 'page3' then begin
                    button_sound;
                    page_process := 'page2';
                    continue;
                  end;
                end;
              12:
                begin
                  if page_process = 'page1' then begin
                    button_sound;
                    page_process := 'page2';
                    continue;
                  end;
                  if page_process = 'page2' then begin
                    button_sound;
                    page_process := 'page3';
                    continue;
                  end;
                end;                                                                                                                          
            end;
            mouse_x := 0;
            mouse_y := 0;
          end;
        end;
      end;
    'shop':
      begin
        for i := 7 to 12 do 
        begin
          if (moving_mouse_x > round(button_x[i] - 4.5 * dx - size[i] - dr)) and (moving_mouse_x < round(button_x[i] + 4.5 * dx + size[i] + dr)) and (moving_mouse_y > round(button_y[i] - 1.5 * dy - size[i] - dr)) and (moving_mouse_y < round(button_y[i] + 1.5 * dy + size[i] + dr)) then begin
            if size[i] <> 6 then inc(size[i], 2);                                                                                                                                                                                                                                                              
            if button_color[i] <> active_color then button_color[i] := highlighted_color;
          end
          else begin
            if size[i] <> 0 then dec(size[i], 2);
            if button_color[i] <> active_color then button_color[i] := deactive_color;
          end;
          if (mouse_x > round(button_x[i] - 4.5 * dx - size[i] - dr)) and (mouse_x < round(button_x[i] + 4.5 * dx + size[i] + dr)) and (mouse_y > round(button_y[i] - 1.5 * dy - size[i] - dr)) and (mouse_y < round(button_y[i] + 1.5 * dy + size[i] + dr)) then begin
            case i of
              7:
                begin
                  if local_process = 'themes' then button_sound;
                  local_process := 'stories';
                  page_process := 'page1';
                  button_color[7] := active_color;
                  button_color[8] := deactive_color;
                end;
              8:
                begin
                  if local_process = 'stories' then button_sound;
                  local_process := 'themes';
                  page_process := 'page1';
                  button_color[8] := active_color;
                  button_color[7] := deactive_color;
                end;
              9: 
                begin
                  button_sound;
                  public_process := 'menu';
                end;
              10:
                begin
                  if (local_process <> 'themes') then begin
                    if page_process = 'page2' then begin
                      button_sound;
                      page_process := 'page1';
                      continue;
                    end;
                    if page_process = 'page3' then begin
                      button_sound;
                      page_process := 'page2';
                      continue;
                    end;
                  end;
                end;
              12:
                begin
                  if (local_process <> 'themes') then begin
                    if page_process = 'page1' then begin
                      button_sound;
                      page_process := 'page2';
                      continue;
                    end;
                    if page_process = 'page2' then begin
                      button_sound;
                      page_process := 'page3';
                      continue;
                    end;
                  end;
                end;                                                                                                                          
            end;
            mouse_x := 0;
            mouse_y := 0;
          end;
        end;
        for i := 13 to 18 do 
        begin
          if (moving_mouse_x > round(button_x[i] - 4 * dx - size[i] - dr)) and (moving_mouse_x < round(button_x[i] + 4 * dx + size[i] + dr)) and (moving_mouse_y > round(button_y[i] - 1 * dy - size[i] - dr)) and (moving_mouse_y < round(button_y[i] + 1 * dy + size[i] + dr)) then begin
            if size[i] <> 6 then inc(size[i], 2);
            button_color[i] := highlighted_color;
          end
          else begin
            if size[i] <> 0 then dec(size[i], 2);
            button_color[i] := deactive_color;
          end;  
          if (mouse_x > round(button_x[i] - 4 * dx - size[i] - dr)) and (mouse_x < round(button_x[i] + 4 * dx + size[i] + dr)) and (mouse_y > round(button_y[i] - 1 * dy - size[i] - dr)) and (mouse_y < round(button_y[i] + 1 * dy + size[i] + dr)) then begin
            case local_process of
              'stories': 
                begin
                  case page_process of
                    'page1':
                      begin
                        if button_availability[1, i] = 'available' then begin
                          get_money;
                          if amount_of_money < 5 then begin
                            error_sound;
                            clear_mouse_xy;
                            occasions('buy_story');
                          end;
                          if amount_of_money >= 5 then begin
                            money_sound;
                            inc(stats_str[1]);
                            rewrite_stats;
                            button_availability[1, i] := 'unavailable';
                            dec(amount_of_money, 5);
                          end;                          
                          rewrite_money;
                          continue;
                        end;
                        if button_availability[1, i] = 'unavailable' then begin
                          error_sound;
                          clear_mouse_xy;
                          occasions('try_story');
                        end;
                      end;
                    'page2':
                      begin
                        if button_availability[2, i] = 'available' then begin
                          get_money;
                          if amount_of_money < 5 then begin
                            error_sound;
                            clear_mouse_xy;
                            occasions('buy_story');
                          end;
                          if amount_of_money >= 5 then begin
                            money_sound;
                            inc(stats_str[1]);
                            rewrite_stats;
                            button_availability[2, i] := 'unavailable';
                            dec(amount_of_money, 5);
                          end;
                          rewrite_money;
                          continue;
                        end;
                        if button_availability[2, i] = 'unavailable' then begin
                          error_sound;
                          clear_mouse_xy;
                          occasions('try_story');
                        end;
                      end;
                    'page3':
                      begin
                        if button_availability[3, i] = 'available' then begin
                          get_money;
                          if amount_of_money < 5 then begin
                            error_sound;
                            clear_mouse_xy;
                            occasions('buy_story');
                          end;
                          if amount_of_money >= 5 then begin
                            money_sound;
                            inc(stats_str[1]);
                            rewrite_stats;
                            button_availability[3, i] := 'unavailable';
                            dec(amount_of_money, 5);
                          end;                          
                          rewrite_money;
                          continue;
                        end;
                        if button_availability[3, i] = 'unavailable' then begin
                          error_sound;
                          clear_mouse_xy;
                          occasions('try_story');
                        end;
                      end;
                  end; 
                end;
              'themes': 
                begin
                  get_money;
                  if button_availability[4, i] = 'available' then begin
                    if amount_of_money >= 10 then begin
                      money_sound;
                      inc(stats_str[1]);
                      rewrite_stats;
                      button_availability[4, i] := 'unavailable';
                      dec(amount_of_money, 10);
                      rewrite_money;
                      continue;
                    end;
                    if amount_of_money < 10 then begin
                      error_sound;
                      occasions('buy_story');
                    end;
                    rewrite_money;
                    continue;
                  end;
                  if (button_availability[4, i] = 'unavailable') or (button_availability[4, i] = 'using') then begin
                    error_sound;
                    occasions('try_story');
                  end;
                  rewrite_button_availability;
                end;
            end;
            mouse_x := 0;
            mouse_y := 0;
          end;
        end;
      end;
    'purchases':
      begin
        for i := 7 to 12 do 
        begin
          if (moving_mouse_x > round(button_x[i] - 4.5 * dx - size[i] - dr)) and (moving_mouse_x < round(button_x[i] + 4.5 * dx + size[i] + dr)) and (moving_mouse_y > round(button_y[i] - 1.5 * dy - size[i] - dr)) and (moving_mouse_y < round(button_y[i] + 1.5 * dy + size[i] + dr)) then begin
            if size[i] <> 6 then inc(size[i], 2);                                                                                                                                                                                                                                                              
            if button_color[i] <> active_color then button_color[i] := highlighted_color;
          end
          else begin
            if size[i] <> 0 then dec(size[i], 2);
            if button_color[i] <> active_color then button_color[i] := deactive_color;
          end;
          if (mouse_x > round(button_x[i] - 4.5 * dx - size[i] - dr)) and (mouse_x < round(button_x[i] + 4.5 * dx + size[i] + dr)) and (mouse_y > round(button_y[i] - 1.5 * dy - size[i] - dr)) and (mouse_y < round(button_y[i] + 1.5 * dy + size[i] + dr)) then begin
            case i of
              7:
                begin
                  button_sound;
                  local_process := 'stories';
                  page_process := 'page1';
                  good_reading := '';
                  button_color[7] := active_color;
                  button_color[8] := deactive_color;
                end;
              8:
                begin
                  button_sound;
                  local_process := 'themes';
                  page_process := 'page1';
                  good_reading := '';
                  button_color[8] := active_color;
                  button_color[7] := deactive_color;
                end;
              9: 
                begin
                  button_sound;
                  if good_reading <> '' then begin
                    good_reading := '';
                    continue;
                  end;
                  public_process := 'menu';
                end;
              10:
                if good_reading = '' then
                begin
                  if (local_process <> 'themes') then begin
                    if page_process = 'page2' then begin
                      button_sound;
                      page_process := 'page1';
                      continue;
                    end;
                    if page_process = 'page3' then begin
                      button_sound;
                      page_process := 'page2';
                      continue;
                    end;
                  end;
                end;
              {11: 
                if (public_process = 'purchases') and (good_reading = '') then begin
                  button_sound;
                  restore_purchases;
                  stats_str[1] := 0;
                  rewrite_stats;
                  occasions('restore_purchases');
                end;}
              12: 
                if good_reading = '' then
                begin
                  if (local_process <> 'themes') then begin
                    if page_process = 'page1' then begin
                      button_sound;
                      page_process := 'page2';
                      continue;
                    end;
                    if page_process = 'page2' then begin
                      button_sound;
                      page_process := 'page3';
                      continue;
                    end;
                  end;
                end;   
            end;
          end;
        end;
        for i := 13 to 18 do 
        begin
          if (moving_mouse_x > round(button_x[i] - 4 * dx - size[i] - dr)) and (moving_mouse_x < round(button_x[i] + 4 * dx + size[i] + dr)) and (moving_mouse_y > round(button_y[i] - 1 * dy - size[i] - dr)) and (moving_mouse_y < round(button_y[i] + 1 * dy + size[i] + dr)) then begin
            if size[i] <> 6 then inc(size[i], 2);
            button_color[i] := highlighted_color;
          end
          else begin
            if size[i] <> 0 then dec(size[i], 2);
            button_color[i] := deactive_color;
          end;
          if (mouse_x > round(button_x[i] - 4 * dx - size[i] - dr)) and (mouse_x < round(button_x[i] + 4 * dx + size[i] + dr)) and (mouse_y > round(button_y[i] - 1 * dy - size[i] - dr)) and (mouse_y < round(button_y[i] + 1 * dy + size[i] + dr)) then begin
            case local_process of
              'stories': 
                begin
                  case page_process of
                    'page1':
                      begin
                        case i of 
                          13: 
                            begin
                              if (button_availability[1, 13] = 'unavailable') and (good_reading = '') then begin
                                button_sound;
                                good_reading := 'story1';
                              end;
                              if (button_availability[1, 13] = 'available') and (good_reading = '') then begin
                                error_sound;
                                clear_mouse_xy;
                                occasions('closed');
                              end;
                            end;
                          14: 
                            begin
                              if (button_availability[1, 14] = 'unavailable') and (good_reading = '') then begin
                                button_sound;
                                good_reading := 'story2';
                              end;
                              if (button_availability[1, 14] = 'available') and (good_reading = '') then begin
                                error_sound;
                                clear_mouse_xy;
                                occasions('closed');
                              end;
                            end;
                          15: 
                            begin
                              if (button_availability[1, 15] = 'unavailable') and (good_reading = '') then begin
                                button_sound;
                                good_reading := 'story3';
                              end;
                              if (button_availability[1, 15] = 'available') and (good_reading = '') then begin
                                error_sound;
                                clear_mouse_xy;
                                occasions('closed');
                              end;
                            end;
                          16: 
                            begin
                              if (button_availability[1, 16] = 'unavailable') and (good_reading = '') then begin
                                button_sound;
                                good_reading := 'story4';
                              end; 
                              if (button_availability[1, 16] = 'available') and (good_reading = '') then begin
                                error_sound;
                                clear_mouse_xy;
                                occasions('closed');
                              end;
                            end;
                          17: 
                            begin
                              if (button_availability[1, 17] = 'unavailable') and (good_reading = '') then begin
                                button_sound;
                                good_reading := 'story5';
                              end;
                              if (button_availability[1, 17] = 'available') and (good_reading = '') then begin
                                error_sound;
                                clear_mouse_xy;
                                occasions('closed');
                              end;
                            end;
                          18: 
                            begin
                              if (button_availability[1, 18] = 'unavailable') and (good_reading = '') then begin
                                button_sound;
                                good_reading := 'story6';
                              end;
                              if (button_availability[1, 18] = 'available') and (good_reading = '') then begin
                                error_sound;
                                clear_mouse_xy;
                                occasions('closed');
                              end;
                            end;
                        end;
                      end;
                    'page2':
                      begin
                        case i of 
                          13: 
                            begin
                              if (button_availability[2, 13] = 'unavailable') and (good_reading = '') then begin
                                button_sound;
                                good_reading := 'story7';
                              end;
                              if (button_availability[2, 13] = 'available') and (good_reading = '') then begin
                                error_sound;
                                clear_mouse_xy;
                                occasions('closed');
                              end;
                            end;
                          14: 
                            begin
                              if (button_availability[2, 14] = 'unavailable') and (good_reading = '') then begin
                                button_sound;
                                good_reading := 'story8';
                              end;
                              if (button_availability[2, 14] = 'available') and (good_reading = '') then begin
                                error_sound;
                                clear_mouse_xy;
                                occasions('closed');
                              end;
                            end;
                          15: 
                            begin
                              if (button_availability[2, 15] = 'unavailable') and (good_reading = '') then begin
                                button_sound;
                                good_reading := 'story9';
                              end;
                              if (button_availability[2, 15] = 'available') and (good_reading = '') then begin
                                error_sound;
                                clear_mouse_xy;
                                occasions('closed');
                              end;
                            end;
                          16: 
                            begin
                              if (button_availability[2, 16] = 'unavailable') and (good_reading = '') then begin
                                button_sound;
                                good_reading := 'story10';                            
                              end;
                              if (button_availability[2, 16] = 'available') and (good_reading = '') then begin
                                error_sound;
                                clear_mouse_xy;
                                occasions('closed');
                              end;
                            end;
                          17: 
                            begin
                              if (button_availability[2, 17] = 'unavailable') and (good_reading = '') then begin
                                button_sound;
                                good_reading := 'story11';                            
                              end;
                              if (button_availability[2, 17] = 'available') and (good_reading = '') then begin
                                error_sound;
                                clear_mouse_xy;
                                occasions('closed');
                              end;
                            end;
                          18: 
                            begin
                              if (button_availability[2, 18] = 'unavailable') and (good_reading = '') then begin
                                button_sound;
                                good_reading := 'story12';                            
                              end;
                              if (button_availability[2, 18] = 'available') and (good_reading = '') then begin
                                error_sound;
                                clear_mouse_xy;
                                occasions('closed');
                              end;
                            end;
                        end;
                      end;
                    'page3':
                      begin
                        case i of 
                          13: 
                            begin
                              if (button_availability[3, 13] = 'unavailable') and (good_reading = '') then begin
                                button_sound;
                                good_reading := 'story13';
                              end;
                              if (button_availability[3, 13] = 'available') and (good_reading = '') then begin
                                error_sound;
                                clear_mouse_xy;
                                occasions('closed');
                              end;
                            end;
                          14: 
                            begin
                              if (button_availability[3, 14] = 'unavailable') and (good_reading = '') then begin
                                button_sound;
                                good_reading := 'story14';
                              end;
                              if (button_availability[3, 14] = 'available') and (good_reading = '') then begin
                                error_sound;
                                clear_mouse_xy;
                                occasions('closed');
                              end;
                            end;
                          15: 
                            begin
                              if (button_availability[3, 15] = 'unavailable') and (good_reading = '') then begin
                                button_sound;
                                good_reading := 'story15';
                              end;
                              if (button_availability[3, 15] = 'available') and (good_reading = '') then begin
                                error_sound;
                                clear_mouse_xy;
                                occasions('closed');
                              end;
                            end;
                          16: 
                            begin
                              if (button_availability[3, 16] = 'unavailable') and (good_reading = '') then begin
                                button_sound;
                                good_reading := 'story16';
                              end;
                              if (button_availability[3, 16] = 'available') and (good_reading = '') then begin
                                error_sound;
                                clear_mouse_xy;
                                occasions('closed');
                              end;
                            end;
                          17: 
                            begin
                              if (button_availability[3, 17] = 'unavailable') and (good_reading = '') then begin
                                button_sound;
                                good_reading := 'story17';
                              end;
                              if (button_availability[3, 17] = 'available') and (good_reading = '') then begin
                                error_sound;
                                clear_mouse_xy;
                                occasions('closed');
                              end;
                            end;
                          18: 
                            begin
                              if (button_availability[3, 18] = 'unavailable') and (good_reading = '') then begin
                                button_sound;
                                good_reading := 'story18';
                              end;
                              if (button_availability[3, 18] = 'available') and (good_reading = '') then begin
                                error_sound;
                                clear_mouse_xy;
                                occasions('closed');
                              end;
                            end;
                        end;
                      end;
                  end; 
                end;
              'themes': 
                begin
                  case i of 
                    13:
                      begin
                        if button_availability[4, 13] = 'using' then begin
                          button_sound;
                          button_availability[4, 13] := 'unavailable';
                          rewrite_theme_using('default');
                          continue;
                        end;
                        if button_availability[4, 13] = 'unavailable' then begin
                          button_sound;
                          button_availability[4, 13] := 'using';
                          rewrite_theme_using('theme1');
                          if button_availability[4, 14] = 'using' then button_availability[4, 14] := 'unavailable';
                          if button_availability[4, 15] = 'using' then button_availability[4, 15] := 'unavailable';
                        end;
                        if button_availability[4, 13] = 'available' then begin
                          error_sound;
                          clear_mouse_xy;
                          occasions('closed');
                        end;
                      end;
                    14:
                      begin
                        if button_availability[4, 14] = 'using' then begin
                          button_sound;
                          button_availability[4, 14] := 'unavailable';
                          rewrite_theme_using('default');
                          continue;
                        end;
                        if button_availability[4, 14] = 'unavailable' then begin
                          button_sound;
                          button_availability[4, 14] := 'using';
                          rewrite_theme_using('theme2');
                          if button_availability[4, 13] = 'using' then button_availability[4, 13] := 'unavailable';
                          if button_availability[4, 15] = 'using' then button_availability[4, 15] := 'unavailable';
                        end;
                        if button_availability[4, 14] = 'available' then begin
                          error_sound;
                          clear_mouse_xy;
                          occasions('closed');
                        end;
                      end;
                    15:
                      begin
                        if button_availability[4, 15] = 'using' then begin
                          button_sound;
                          button_availability[4, 15] := 'unavailable';
                          rewrite_theme_using('default');
                          continue;
                        end;
                        if button_availability[4, 15] = 'unavailable' then begin
                          button_sound;
                          button_availability[4, 15] := 'using';
                          rewrite_theme_using('theme3');
                          if button_availability[4, 13] = 'using' then button_availability[4, 13] := 'unavailable';
                          if button_availability[4, 14] = 'using' then button_availability[4, 14] := 'unavailable';
                        end;
                        if button_availability[4, 15] = 'available' then begin
                          error_sound;
                          clear_mouse_xy;
                          occasions('closed');
                        end;
                      end;
                  end;                  
                end;
            end;
            mouse_x := 0;
            mouse_y := 0;
          end;
        end;
      end;
    'options':
      begin
        for i := 8 to 9 do 
        begin
          if (moving_mouse_x > round(button_x[i] - 4.5 * dx - size[i] - dr)) and (moving_mouse_x < round(button_x[i] + 4.5 * dx + size[i] + dr)) and (moving_mouse_y > round(button_y[i] - 1.5 * dy - size[i] - dr)) and (moving_mouse_y < round(button_y[i] + 1.5 * dy + size[i] + dr)) then begin
            if size[i] <> 6 then inc(size[i], 2);                                                                                                                                                                                                                                                              
            if button_color[i] <> active_color then button_color[i] := highlighted_color;
          end
          else begin
            if size[i] <> 0 then dec(size[i], 2);
            if button_color[i] <> active_color then button_color[i] := deactive_color;
          end;
          if (mouse_x > round(button_x[i] - 4.5 * dx - size[i] - dr)) and (mouse_x < round(button_x[i] + 4.5 * dx + size[i] + dr)) and (mouse_y > round(button_y[i] - 1.5 * dy - size[i] - dr)) and (mouse_y < round(button_y[i] + 1.5 * dy + size[i] + dr)) then begin
            if good_reading = 'stats' then begin
              case i of 
                8: 
                  begin
                    button_sound;
                    restore_stats;
                    restore_purchases;
                    occasions('restore_stats');
                  end;
              end;
            end;
            case i of
              9: 
                begin
                  button_sound;
                  if good_reading = '' then public_process := 'menu'
                  else good_reading := '';
                end;
            end; 
          end;
        end;
        for i := 13 to 18 do 
        begin
          if (moving_mouse_x > round(button_x[i] - 4 * dx - size[i] - dr)) and (moving_mouse_x < round(button_x[i] + 4 * dx + size[i] + dr)) and (moving_mouse_y > round(button_y[i] - 1 * dy - size[i] - dr)) and (moving_mouse_y < round(button_y[i] + 1 * dy + size[i] + dr)) then begin
            if size[i] <> 6 then inc(size[i], 2);
            button_color[i] := highlighted_color;
          end
          else begin
            if size[i] <> 0 then dec(size[i], 2);
            button_color[i] := deactive_color;
          end;  
          if (mouse_x > round(button_x[i] - 4 * dx - size[i] - dr)) and (mouse_x < round(button_x[i] + 4 * dx + size[i] + dr)) and (mouse_y > round(button_y[i] - 1 * dy - size[i] - dr)) and (mouse_y < round(button_y[i] + 1 * dy + size[i] + dr)) then begin
            get_options;
            if good_reading = '' then begin
              case i of
                13:
                  begin
                    button_sound;
                    if options_str[1] = 'YES' then begin
                      options_str[1] := 'NO';
                      rewrite_options;
                      continue;
                    end
                    else begin
                      options_str[1] := 'YES';
                      rewrite_options;
                    end;                    
                  end;
                14:
                  begin
                    button_sound;
                    if options_str[2] = 'ENGLISH' then begin
                      options_str[2] := 'RUSSIAN';
                      rewrite_options;
                      fill_str;
                      initialize_pictures;
                      continue;
                    end
                    else begin
                      options_str[2] := 'ENGLISH';
                      rewrite_options;
                      fill_str;
                      initialize_pictures;
                    end;
                  end;
                15:
                  begin
                    button_sound;
                    if options_str[3] = 'YES' then begin
                      options_str[3] := 'NO';
                      rewrite_options;
                      continue;
                    end
                    else begin
                      options_str[3] := 'YES';
                      rewrite_options;
                    end;
                  end;
                16:
                  begin
                    button_sound;    
                    good_reading := 'stats';
                  end;
                17:
                  begin
                    button_sound;
                    if options_str[5] = 'YES' then begin
                      options_str[5] := 'NO';
                      rewrite_options;
                      continue;
                    end
                    else begin
                      options_str[5] := 'YES';
                      rewrite_options;
                    end;
                  end;
                18:
                  begin
                    button_sound;
                    if options_str[6] = 'YES' then begin
                      options_str[6] := 'NO';
                      rewrite_options;
                      continue;
                    end
                    else begin
                      options_str[6] := 'YES';
                      rewrite_options;
                    end;
                  end;
              end;
            end;          
          end;
        end;
      end;  
    'developers': 
      begin
        for i := 9 to 9 do 
        begin
          if (moving_mouse_x > round(button_x[i] - 4.5 * dx - size[i] - dr)) and (moving_mouse_x < round(button_x[i] + 4.5 * dx + size[i] + dr)) and (moving_mouse_y > round(button_y[i] - 1.5 * dy - size[i] - dr)) and (moving_mouse_y < round(button_y[i] + 1.5 * dy + size[i] + dr)) then begin
            if size[i] <> 6 then inc(size[i], 2);                                                                                                                                                                                                                                                              
            if button_color[i] <> active_color then button_color[i] := highlighted_color;
          end
          else begin
            if size[i] <> 0 then dec(size[i], 2);
            if button_color[i] <> active_color then button_color[i] := deactive_color;
          end;
          if (mouse_x > round(button_x[i] - 4.5 * dx - size[i] - dr)) and (mouse_x < round(button_x[i] + 4.5 * dx + size[i] + dr)) and (mouse_y > round(button_y[i] - 1.5 * dy - size[i] - dr)) and (mouse_y < round(button_y[i] + 1.5 * dy + size[i] + dr)) then begin
            button_sound;
            case i of
              9: 
                begin
                  public_process := 'menu';
                  mouse_x := 0;
                  mouse_y := 0;
                end;
            end;
          end;
        end;
      end;
  end;
end;


{----------------------------------------------------------------------------menu-----------------------------------------------------------------------------}
procedure menu;
var
  i: integer;
begin
  local_process := '';
  for i := 1 to 5 do 
  begin
    size[i] := 0; 
    button_color[i] := deactive_color;
  end;
  app_size := 0;
  angle_alpha[1] := 240;
  angle_alpha[2] := 300;
  angle_alpha[3] := 0;
  angle_alpha[4] := 60;
  angle_alpha[5] := 120;
  angle_alpha[6] := 180;
  if options_str[3] = 'YES' then angle_alpha_delta := 0.2
  else angle_alpha_delta := 0;  
  lockdrawing;
  repeat
    onmouse;
    clearwindow(background_color);
    //app icon drawing
    rectangle(center_x - 4 * dx - dr - app_size, center_y - 2 * dy - dr - app_size, center_x + 4 * dx + dr + app_size, center_y + 2 * dy + dr + app_size);
    rectangle(center_x - 4 * dx  - app_size, center_y - 2 * dy  - app_size, center_x + 4 * dx + app_size, center_y + 2 * dy + app_size);
    app_icon.Draw(center_x - 4 * dx + 1 - app_size, center_y - 2 * dy + 1 - app_size, 8 * dx - 2 + 2 * app_size, 4 * dy - 2 + 2 * app_size);
    //changing x,y coordinates of 5 menu buttons 
    for i := 1 to 6 do 
    begin
      button_x[i] := round(cos(angle_alpha[i] * pi / 180) * radius_x + center_x);
      button_y[i] := round(sin(angle_alpha[i] * pi / 180) * radius_y + center_y);
    end;
    //drawing buttons
    button_1(button_x[1], button_y[1], size[1], global_str[2], button_color[1]);
    button_1(button_x[2], button_y[2], size[2], global_str[3], button_color[2]);
    button_1(button_x[3], button_y[3], size[3], global_str[4], button_color[3]);
    button_1(button_x[4], button_y[4], size[4], global_str[5], button_color[4]);
    button_1(button_x[5], button_y[5], size[5], global_str[6], button_color[5]);
    button_1(button_x[6], button_y[6], size[6], global_str[7], button_color[6]);
    //checking for pressed or moved button;
    check_button;
    
    //increasing angle
    for i := 1 to 6 do 
    begin
      angle_alpha[i] := angle_alpha[i] + angle_alpha_delta;
    end;
    if angle_alpha[3] = 360  then begin
      for i := 1 to 6 do 
      begin
        angle_alpha[i] := angle_alpha[i] - 360;
      end;
    end;      
    //checking for pressed or moved button;
    onmouse;
    check_button;
    clear_mouse_xy;
    check_music;
    if options_str[1] = 'YES' then player.Volume := 1000
    else player.Volume := 0;
    redraw;
  until public_process <> 'menu';
end;
{--------------------------------------------------------------------------shop--------------------------------------------------------------------}
{--------------------------------------------------------------------------goods--------------------------------------------------------------------}
//procedure of displaying money in the shop
procedure money;
var
  str: string;
begin
  rectangle(round(button_x[11] - 4.5 * dx - dr), round(button_y[11] - 1.5 * dy - dr), round(button_x[11] + 4.5 * dx  + dr), round(button_y[11] + 1.5 * dy  + dr));
  rectangle(round(button_x[11] - 4.5 * dx ), round(button_y[11] - 1.5 * dy ), round(button_x[11] + 4.5 * dx ), round(button_y[11] + 1.5 * dy ));
  setbrushstyle(bsclear);
  str := global_str[13] + ' ' + inttostr(amount_of_money);
  drawtextcentered(round(button_x[11] - 4.5 * dx ), round(button_y[11] - 1.5 * dy ), round(button_x[11] + 4.5 * dx ), round(button_y[11] + 1.5 * dy ), str);
  setbrushstyle(bssolid);
end;
//drawing 1 good
procedure get_good(x, y: integer);
begin
  rectangle(x - 4 * dx - dr, y - 3 * dy - dr, x + 4 * dx + dr, y + 3 * dy + dr);
  rectangle(x - 4 * dx, y - 3 * dy, x + 4 * dx, y + 3 * dy);
end;
//dwaing buttons and goods in the shop
procedure goods_list;
var
  i: integer;
begin
  case local_process of 
    'stories': 
      begin
        for i := 13 to 18 do 
        begin
          case page_process of 
            'page1': button_3(button_x[i], button_y[i], size[i], button_color[i], button_availability[1, i]);
            'page2': button_3(button_x[i], button_y[i], size[i], button_color[i], button_availability[2, i]);
            'page3': button_3(button_x[i], button_y[i], size[i], button_color[i], button_availability[3, i]);
          end;
          get_good(good_x[i], good_y[i]);
        end;
      end;
    'themes': 
      begin
        for i := 13 to 15 do 
        begin
          case page_process of 
            'page1': 
              begin
                if button_availability[4, i] = 'using' then button_3(button_x[i], button_y[i], size[i], active_color, button_availability[4, i])
                else button_3(button_x[i], button_y[i], size[i], button_color[i], button_availability[4, i]);
              end;
          end;
          get_good(good_x[i], good_y[i]);
        end;
      end;
  end;
  pic_icon;
end;
//shop main
procedure shop;
var
  i: integer;
begin
  local_process := 'stories';
  page_process := 'page1';
  for i := 7 to 18 do 
  begin
    size[i] := 0; 
    button_color[i] := deactive_color;
  end;
  button_color[7] := active_color;                
  lockdrawing;
  repeat
    onmouse;
    clearwindow(background_color);
    mid_window(global_str[4]);
    if local_process <> 'themes' then right_window(global_str[43]);
    //drawing buttons
    button_2(button_x[7], button_y[7], size[7], global_str[16], button_color[7]);
    button_2(button_x[8], button_y[8], size[8], global_str[17], button_color[8]);
    button_2(button_x[9], button_y[9], size[9], global_str[10], button_color[9]);
    button_2(button_x[10], button_y[10], size[10], global_str[14], button_color[10]);
    button_2(button_x[12], button_y[12], size[12], global_str[15], button_color[12]);
    rewrite_button_availability;
    get_button_availability(local_process, page_process);
    goods_list;
    money;
    //checking for pressed or moved button;
    onmouse;
    check_button;
    clear_mouse_xy;
    check_music;
    if options_str[1] = 'YES' then player.Volume := 1000
    else player.Volume := 0;
    redraw;
  until public_process <> 'shop';
end;
{--------------------------------------------------------------------------purchases----------------------------------------------------------------}
procedure purchases;
var
  i: integer;
begin
  clear_mouse_xy;
  local_process := 'stories';
  page_process := 'page1';
  good_reading := '';
  for i := 7 to 18 do 
  begin
    size[i] := 0; 
    button_color[i] := deactive_color;
  end;
  button_color[7] := active_color;                
  lockdrawing;
  repeat
    onmouse;
    clearwindow(background_color);
    if good_reading <> '' then left_window;
    mid_window(global_str[5]);
    if local_process <> 'themes' then right_window(global_str[43]);
    //drawing buttons
    button_2(button_x[7], button_y[7], size[7], global_str[16], button_color[7]);
    button_2(button_x[8], button_y[8], size[8], global_str[17], button_color[8]);
    button_2(button_x[9], button_y[9], size[9], global_str[10], button_color[9]);
    if good_reading = '' then begin
      button_2(button_x[10], button_y[10], size[10], global_str[14], button_color[10]);
      {button_2(button_x[11], button_y[11], size[11], global_str[20], button_color[11]);}
      button_2(button_x[12], button_y[12], size[12], global_str[15], button_color[12]);
    end; 
    rewrite_button_availability;
    get_button_availability(local_process, page_process);
    if good_reading = '' then goods_list
    else pic_big;    
    //checking for pressed or moved button;
    onmouse;
    check_button;
    clear_mouse_xy;
    check_music;
    if options_str[1] = 'YES' then player.Volume := 1000
    else player.Volume := 0;
    redraw;
  until public_process <> 'purchases';
end;
{--------------------------------------------------------------------------rules--------------------------------------------------------------------}
procedure rules;
var
  i: integer;
begin
  local_process := 'rules';
  page_process := 'page1';
  good_reading := 'rule1';
  for i := 7 to 18 do 
  begin
    size[i] := 0; 
    button_color[i] := deactive_color;
  end;
  button_color[7] := active_color;                
  lockdrawing;
  repeat
    onmouse;
    clearwindow(background_color);
    mid_window(global_str[3]);
    right_window(global_str[43]);
    //drawing buttons    
    button_2(button_x[9], button_y[9], size[9], global_str[10], button_color[9]);
    button_2(button_x[10], button_y[10], size[10], global_str[14], button_color[10]);
    button_2(button_x[12], button_y[12], size[12], global_str[15], button_color[12]);    
    rewrite_button_availability;
    pic_big;
    //checking for pressed or moved button;
    onmouse;
    check_button;
    clear_mouse_xy;
    check_music;
    if options_str[1] = 'YES' then player.Volume := 1000
    else player.Volume := 0;
    redraw;
  until public_process <> 'rules';
end;
//drawing options button
procedure options_button(x, y, size: integer; button_color: color; str: string);
begin
  rectangle(round(x - 4 * dx - size - dr), round(y - 1 * dy - size - dr), round(x + 4 * dx + size + dr), round(y + 1 * dy + size + dr));
  setbrushcolor(button_color);
  fillrectangle(round(x - 4 * dx - size), round(y - 1 * dy - size), round(x + 4 * dx + size), round(y + 1 * dy + size));
  setbrushcolor(color_2);
  rectangle(round(x - 3 * dx - size), round(y - 0.5 * dy - size), round(x + 3 * dx + size), round(y + 0.5 * dy + size));
  setbrushstyle(bsclear);
  drawtextcentered(round(x - 3.5 * dx - size), round(y - 0.5 * dy - size), round(x + 3.5 * dx + size), round(y + 0.5 * dy + size), str);
  setbrushstyle(bssolid);
end;
//drawing options interface(buttons,pictures)
procedure options_interface;
var
  i: integer;
begin
  get_options;
  if options_str[1] = 'YES' then options_button(button_x[13], button_y[13], size[13], button_color[13], global_str[25])
  else options_button(button_x[13], button_y[13], size[13], button_color[13], global_str[26]);
  options_button(button_x[14], button_y[14], size[14], button_color[14], global_str[27]);
  if options_str[3] = 'YES' then options_button(button_x[15], button_y[15], size[15], button_color[15], global_str[25])
  else options_button(button_x[15], button_y[15], size[15], button_color[15], global_str[26]);
  options_button(button_x[16], button_y[16], size[16], button_color[16], global_str[28]);
  if options_str[5] = 'YES' then options_button(button_x[17], button_y[17], size[17], button_color[17], global_str[25])
  else options_button(button_x[17], button_y[17], size[17], button_color[17], global_str[26]);
  if options_str[6] = 'YES' then options_button(button_x[18], button_y[18], size[18], button_color[18], global_str[25])
  else options_button(button_x[18], button_y[18], size[18], button_color[18], global_str[26]);
  for i := 13 to 18 do
  begin
    get_good(good_x[i], good_y[i]);
  end;
end;
{--------------------------------------------------------------------------options--------------------------------------------------------------------}
procedure options;
var
  i: integer;
begin
  local_process := 'options';
  page_process := 'page1';
  good_reading := '';
  for i := 8 to 18 do 
  begin
    size[i] := 0; 
    button_color[i] := deactive_color;    
  end;  
  lockdrawing;
  repeat
    onmouse;
    clearwindow(background_color);
    if good_reading <> '' then left_window;
    mid_window(global_str[6]);
    button_2(button_x[9], button_y[9], size[9], global_str[10], button_color[9]); 
    if good_reading = '' then options_interface;
    pic_icon;
    pic_big;
    //checking for pressed or moved button;
    onmouse;
    check_button;
    clear_mouse_xy;
    check_music;
    if options_str[1] = 'YES' then player.Volume := 1000
    else player.Volume := 0;
    redraw;
  until public_process <> 'options';
end;


procedure developers;
var
  i: integer;
begin
  for i := 9 to 9 do 
  begin
    size[i] := 0; 
    button_color[i] := deactive_color; 
  end;
  lockdrawing;
  repeat
    onmouse;
    clearwindow(background_color);
    mid_window(global_str[41]);
    button_2(button_x[9], button_y[9], size[9], global_str[10], button_color[9]); 
    pic_big;
    //checking for pressed or moved button;
    onmouse;
    check_button;
    clear_mouse_xy;
    check_music;
    if options_str[1] = 'YES' then player.Volume := 1000
    else player.Volume := 0;
    redraw;
  until public_process <> 'developers';
end;
//drawing loading screen during files loading
procedure loading_window;
begin
  clearwindow(background_color);
  button_1(center_x, center_y, 0, global_str[1] + '...', deactive_color);
end;
{----------------------------------------------------------------begin-------------------------------------------------------------------}
begin
  SetSmoothingOn;
  setwindowcaption('MorseBall');
  setwindowsize(screenwidth, screenheight);
  centerwindow; 
  setfontname('calibri');
  setfontsize((windowwidth div 100) + 6); 
  //global_str
  fill_str;
  loading_window;
  sleep(1000);   
  initialize;
  initialize_pictures;
  public_process := 'menu';
  local_process := '';
  page_process := '';
  t := timer.create(1000, dec_timer);
  time := 260;
  t.start;
  menu_music;
  //choose public process
  repeat
    case public_process of 
      'menu': 
        begin
          clear_mouse_xy;
          menu;
        end;
      'mode_choose': 
        begin
          clear_mouse_xy;
          player.stop;
          t.stop;
          main_play;          
          public_process := 'menu';
          time := 260;
          t.start;
          menu_music;
        end;
      'rules': 
        begin
          rules;
        end;
      'shop': 
        begin
          clear_mouse_xy;
          shop;
        end;
      'purchases': 
        begin
          clear_mouse_xy;
          purchases;
        end;
      'options': 
        begin
          clear_mouse_xy;
          options;
        end;
      'developers':
        begin
          clear_mouse_xy;
          developers;
          public_process := 'menu';
        end;
    end;
  until false;
end.