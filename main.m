close all; clear all; clc;                                                                                                                        

fieldWidth = 4; %Ширина поля
fieldHeight = 4; %Высота поля
minesCount = 2; %Число мин
agentIsAlive = true; %Жив ли агент
iter = 0; %Номер итерации

%Генерация среды
[GridTrue, agent] = GenerateGrid(fieldWidth, fieldHeight, minesCount); 

GridVisible = zeros(fieldHeight, fieldWidth); %Среда, известная агенту
for i=1:fieldHeight
     for j=1:fieldWidth
         GridVisible(i,j) = '-'; %Изначально вся среда не известна агенту
     end;
end;
GridVisible(agent(1), agent(2)) = GridTrue(agent(1), agent(2)); %Точка, в которой появился агент исследована им

figure(111)
    VizualizeGrid(fieldWidth, fieldHeight, GridTrue, agent);
    title("Изначальная матрица");

h = fieldHeight; w = fieldWidth;
turn = "";

while agentIsAlive %Цикл поведения агента
   if GridVisible(agent(1), agent(2)) == 'M' %Если агент наступил на мину
       agentIsAlive = false; %Агент подрывается и цикл прекращается
       break;
   else
       iter = iter + 1;
           i = agent(1); j = agent(2);
           %Перерасчёт уровнем опасности всех соседних клеток
           if i > 1 if Suspectable(GridVisible(i-1,j)) 
              GridVisible(i-1,j) = Suspection(i-1, j, GridVisible, w, h); end; end;
           if i < h if Suspectable(GridVisible(i+1,j)) 
              GridVisible(i+1,j) = Suspection(i+1, j, GridVisible, w, h); end; end;
           if j > 1 if Suspectable(GridVisible(i,j-1)) 
              GridVisible(i,j-1) = Suspection(i, j-1, GridVisible, w, h); end; end;
           if j < w if Suspectable(GridVisible(i,j+1)) 
              GridVisible(i,j+1) = Suspection(i, j+1, GridVisible, w, h); end; end;
       figure(iter)
            VizualizeGrid(fieldWidth, fieldHeight, GridVisible, agent);
            title("Промежуточное положение (шаг " + iter + ")");
   end
   
   %Если агент не знает, куда идти в следующей итерации
   if turn.strlength() == 0
       trivialMoves = "";
       
       %Проверка тривиального случая: есть соседняя неисследованная безопасная ячейка
       i = agent(1); j = agent(2);
       if i > 1 if Suspection(i-1,j, GridVisible, w, h) == 0 trivialMoves = trivialMoves + "d"; end; end;
       if i < h if Suspection(i+1,j, GridVisible, w, h) == 0 trivialMoves = trivialMoves + "u"; end; end;
       if j > 1 if Suspection(i,j-1, GridVisible, w, h) == 0 trivialMoves = trivialMoves + "l"; end; end;
       if j < w if Suspection(i,j+1, GridVisible, w, h) == 0' trivialMoves = trivialMoves + "r"; end; end;
       
       if(trivialMoves.strlength()>0)
           turn = trivialMoves.extract(randi(trivialMoves.strlength()));
       else
           %Если случай не тривиален
           susGrid = zeros(fieldHeight, fieldWidth); %Матрица уровня опасности
           for i=1:fieldHeight
             for j=1:fieldWidth
               susGrid(i,j) = Suspection(i, j, GridVisible, w, h);
             end
           end
           pathFound = false;
           researchRest=0;
           for r=[0:4] %Вычисление числа ячеек, входящих в перебор поиска пути
              for i=1:h
                for j=1:w
                    seekGrid(i,j) = "0";
                    if Suspection(i,j, GridVisible, w, h) <= r
                        researchRest = researchRest+1;
                    end;
                end
              end
              researchRest = researchRest - 1;
              seekGrid(agent(1), agent(2)) = "";
              
              while researchRest > 0 %Поиск пути в ширину
                  for i=1:h
                    for j=1:w
                       pf = false;
                       if seekGrid(i,j) == "0" %Если данная ячейка - начальная
                           if i > 1 
                               if seekGrid(i-1,j) ~= "0" && Suspection(i-1,j, GridVisible, w, h) <= r
                                   seekGrid(i,j) = seekGrid(i-1, j) + "u"; 
                                   pf = true;
                               end;end;
                           if i < h 
                               if seekGrid(i+1,j) ~= "0" && Suspection(i+1,j, GridVisible, w, h) <= r
                                   seekGrid(i,j) = seekGrid(i+1, j) + "d"; 
                                   pf = true;
                               end;end;
                           if j > 1 
                               if seekGrid(i,j-1) ~= "0" && Suspection(i,j-1, GridVisible, w, h) <= r
                                   seekGrid(i,j) = seekGrid(i, j-1) + "r"; 
                                   pf = true;
                               end;end;
                           if j < w 
                               if seekGrid(i,j+1) ~= "0" && Suspection(i,j+1, GridVisible, w, h) <= r
                                   seekGrid(i,j) = seekGrid(i, j+1) + "l"; 
                                   pf = true;
                               end;end; 
                           if pf researchRest = researchRest - 1; end;
                       end;
                       %Если ячейка не исследована агентом и её уровень опасности не превышает допустимый
                       if (GridVisible(i,j) ~= '-')&&(Suspection(i,j, GridVisible, w, h) <= r)&&(Suspection(i,j, GridVisible, w, h) ~= -1)&&(seekGrid(i,j) ~= "0")&&(seekGrid(i,j) ~= "")&&(~pathFound)
                           turn = seekGrid(i,j);
                           pathFound = true;
                           break;
                       end
                    end;
                    if pathFound 
                        break; end;
                  end;
                  if pathFound 
                        break; end;
              end;
              if pathFound 
                  break; end;
          end;
      end;
    end;
   %Совершить пермещение на одну клетку в соответствии с запланированным маршрутом
   switch turn.extract(1)
       case "d" 
           agent(1) = agent(1) - 1; agent(2) = agent(2);
       case "u" 
           agent(1) = agent(1) + 1; agent(2) = agent(2);
       case "l" 
           agent(1) = agent(1); agent(2) = agent(2) - 1;
       case "r" 
           agent(1) = agent(1); agent(2) = agent(2) + 1;
   end
   turn = turn.eraseBetween(1,1);

   GridVisible(agent(1), agent(2)) = GridTrue(agent(1), agent(2));
   
   pause(1.5);
end

%Вывод итоговой карты среды
figure(iter + 1)
    VizualizeGrid(fieldWidth, fieldHeight, GridVisible, agent);
    title("Смерть агента (шаг " + (iter+1) + ")");    


%Визуализация среды
function VizualizeGrid(w, h, grd, agent)
    plot(agent(2) + 0.1,agent(1), '-s', 'MarkerSize', 30, 'MarkerFaceColor','g');
    hold on;
    for i=1:h
     for j=1:w
       plot(0,0);
       axis([0 w+1 0 h+1]);
       if grd(i,j) == 'M'
        text(j, i,sprintf('%s',grd(i,j)), 'Color','yellow','FontSize',24);
       elseif grd(i,j) == '+'
        text(j, i,sprintf('%s',grd(i,j)), 'Color','black','FontSize',24);
       elseif grd(i,j) == 'z'
        text(j, i,sprintf('%s',grd(i,j)), 'Color','green','FontSize',24);
       elseif grd(i,j) == '-'
        text(j, i,sprintf('%s',grd(i,j)), 'Color','black','FontSize',24);
       else
        text(j, i,sprintf('%g',grd(i,j)), 'Color','magenta','FontSize',24); end;
     end;
    end;
end

%Генерация среды
function [grd, agent] = GenerateGrid(w, h, mines)
    grd = zeros(h,w);
    for i=1:h
     for j=1:w
       grd(i,j) = '+';
     end;
    end;
    m = mines;
    while m > 0
        rndx = randi(w);
        rndy = randi(h);
        if grd(rndy,rndx) == '+'
            grd(rndy,rndx) = 'M';
            m = m - 1;
        end
    end

    for i=1:h
     for j=1:w
       if grd(i,j) == '+'
           if i > 1 if grd(i-1,j) == 'M' grd(i,j) = 'z'; end; end;
           if i < h if grd(i+1,j) == 'M' grd(i,j) = 'z'; end; end;
           if j > 1 if grd(i,j-1) == 'M' grd(i,j) = 'z'; end; end;
           if j < w if grd(i,j+1) == 'M' grd(i,j) = 'z'; end; end;
       end;
     end;
    end;

    agent = [0,0];
    wexit = 1;
    while wexit > 0
        rndx = randi(w);
        rndy = randi(h);
        if grd(rndy,rndx) ~= 'M'
            agent = [rndy, rndx];
            wexit = 0;
        end
    end
end

%Оценка опасности исследования ячейки с координатами ij
function sus = Suspection(i,j,grd, w, h)
    sus = 0;
    if i > 1 if grd(i-1,j) == 'z' sus = sus + 1; end; end;
    if i < h if grd(i+1,j) == 'z' sus = sus + 1; end; end;
    if j > 1 if grd(i,j-1) == 'z' sus = sus + 1; end; end;
    if j < w if grd(i,j+1) == 'z' sus = sus + 1; end; end;
    if i > 1 if grd(i-1,j) == '+' sus = 0; end; end;
    if i < h if grd(i+1,j) == '+' sus = 0; end; end;
    if j > 1 if grd(i,j-1) == '+' sus = 0; end; end;
    if j < w if grd(i,j+1) == '+' sus = 0; end; end;
    if grd(i,j) == '+' sus = -1; end;
    if grd(i,j) == 'z' sus = -1; end;

end

%Неисследованная ячейка может быть опасна?
function sus = Suspectable(v)
   sus = (v ~= 'M')&&(v ~= 'z')&&(v ~= '+');
end
