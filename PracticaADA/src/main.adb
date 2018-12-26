with PowerPlant_p;
with Ada.Real_Time;
with Ada.Text_IO;

use Ada.Real_Time;
use Ada.Text_IO;


use PowerPlant_p;
with Ada.Numerics.Discrete_Random;


procedure Main is

   -- Numeros aleatorios
   package RandomNumber is new Ada.Numerics.Discrete_Random(ConsumptionVariance_t);

   reactor1: aliased Reactor_t;
   reactor2: aliased Reactor_t;
   reactor3: aliased Reactor_t;

   reactor1.setID(1);
   reactor2.setID(2);
   reactor3.setID(3);

   -- Tarea coordinadora, que comprueba que el reactor funciona
   task type CoordinatorTask(reactorID: Integer) is
      entry ReactorIsAlive;
   end CoordinatorTask;
   task body CoordinatorTask is
   begin
      loop
         select
            accept ReactorIsAlive do
               -- Do nothing
               null;
            end ReactorIsAlive;
         or delay 3.0; -- 3 seconds delay
            -- Timeout actions
            Put_Line("WARNING: notification from reactor " & Integer'Image(reactorID) & " not received. Possible.");
         end select;
      end loop;
   end CoordinatorTask;

   -- Tareas coordinadoras
   reactor1CoordinatorTask: CoordinatorTask(reactor1.getID);
   reactor2CoordinatorTask: CoordinatorTask(reactor2.getID);
   reactor3CoordinatorTask: CoordinatorTask(reactor3.getID);

   task type ControllerTask(rID: Integer);
   task body ControllerTask is
   begin
      case rID is
         when 1 =>
            reactor1CoordinatorTask.ReactorIsAlive;
         when 2 =>
            reactor2CoordinatorTask.ReactorIsAlive;
         when 3 =>
            reactor3CoordinatorTask.ReactorIsAlive;
         when others =>
            null;
      end case;
   end ControllerTask;

   reactor1ControllerTask:ControllerTask(reactor1.getID);
   reactor2ControllerTask:ControllerTask(reactor2.getID);
   reactor3ControllerTask:ControllerTask(reactor3.getID);

   -- Tarea de variación de la temperatura en el reactor
   task type varyTemperatureTask;
   task body varyTemperatureTask is
      randomNumberGeneratorSeed: RandomNumber.Generator;
      tNextRelease: Time;
      tiReleaseInterval:constant Time_Span := Milliseconds(1000);
   begin

      tNextRelease := Clock + tiReleaseInterval;
      loop
         -- Seleccionar un reactor al azar, y subir su temperatura 150ºC
         delay until tNextRelease;
         tNextRelease := tNextRelease + tiReleaseInterval;
      end loop;

   end varyTemperatureTask;

   -- Objeto tarea de variación de la temperatura
   varyTemperature: varyTemperatureTask;

   -- Procedimiento: recoge la temperatura total de los tres reactores
   --                en las variables out1, out2 y out3
   procedure getTotalTemperature(temp1:out Temperature_t; temp2:out Temperature_t; temp3:out Temperature_t) is

      task type p1;
      task body p1 is
      begin
         temp1 := plant1.getOutput;
      end p1;

      task type p2;
      task body p2 is
      begin
         temp2 := plant2.getOutput;
      end p2;

      task type p3;
      task body p3 is
      begin
         temp3 := plant3.getOutput;
      end p3;

      taskp1:p1;
      taskp2:p2;
      taskp3:p3;

   begin
      null;
   end getTotalTemperature;

   -- Tarea Principal que realizará el monitor o tarea coordinadora cada 2 segundos
--     task type ControllerTask;
--     task body ControllerTask is
--        tNextRelease: Time;
--        tiReleaseInterval:constant Time_Span:=Milliseconds(2000);
--
--        -- Temperatura de los 3 reactores
--        reactorTemp:Temperature_t;
--
--        -- Temperatura del nucleo del reactor (la suma de la temp. de los tres reactores)
--        nucleusTemp:Integer;
--        diff:Integer;
--
--  --        type plant_ptr is access all PowerPlant_t;
--  --
--  --        -- 3 reactores nucleares / 1 tarea por reactor nuclear
--  --        first:plant_ptr:=plant1'access;
--  --        second:plant_ptr:=plant2'Access;
--  --        third:plant_ptr:=plant3'Access;
--
--     begin
--        -- Se les asigna un id a cada reactor. Sirve sobre todo para identificarlos.
--  --        plant1.setID(1);
--  --        plant2.setID(2);
--  --        plant3.setID(3);
--
--        tNextRelease := Clock + tiReleaseInterval;
--
--        loop
--
--           getTotalTemperature(temp1, temp2, temp3);
--
--           --Delay de 1 segundo para simular la lectura de la temperatura
--           delay 0.1;
--           -- nucleusTemp := temp1 + temp2 + temp3;
--           --if (temp3 >= temp1 and then temp3 >= temp2) then
--           --first := plant3'access;
--           --if (temp2 > temp1) then
--           --third := plant1'Access;
--           --else
--           --second := plant1'Access;
--           --third := plant2'Access;
--           --end if;
--           --elsif (temp2 > out3 and then temp2 > temp1) then
--           --first:= plant2'access;
--           --if (temp3 >= temp1) then
--           --second := plant3'Access;
--           --third:= plant1'Access;
--           --else
--           --second:= plant1'Access;
--           --end if;
--           --elsif (temp3 >= temp2) then
--           --second:=plant3'Access;
--           --third:=plant2'Access;
--        end if;
--
--
--        -- CASO 1: temperatura es superior a (1500ºC)
--        if (Float(nucleusTemp) >= 1500 and then Float(nucleusTemp) <= 1750) then
--
--           -- Abrir compuerta que reduce la temperatura a 50ºC por segundo
--
--
--           --diff := cityConsumption-nucleusTemp;
--           --third--.setOperation(1);
--           --if (diff >= 2) then second.setOperation(1); else second.setOperation(0); end if;
--           --if (diff >= 3) then first.setOperation(1); else first.setOperation(0); end if;
--           --Put_Line("PELIGRO BAJADA consumo:"&Integer'Image(cityConsumption)&" producción:"&Integer'Image(nucleusTemp));
--
--           -- CASO 2: temperatura es superior a 1750ºC
--        elsif (Float(nucleusTemp) > 1750) then
--
--           --diff := nucleusTemp - cityConsumption;
--           --first--.setOperation(-1);
--           --if (diff >= 2) then second.setOperation(-1); else second.setOperation(0); end if;
--           --if (diff >= 3) then third.setOperation(-1); else third.setOperation(0); end if;
--           --Put_Line("PELIGRO SOBRECARGA consumo:"&Integer'Image(cityConsumption)&" producción:"&Integer'Image(nucleusTemp));
--
--           -- CASO 3: temperatura inferior a 1500ºC
--        else
--
--           -- Unicamente imprimir un mensaje
--           Put_Line("Temperatura estable:" & Integer'Image(nucleusTemp));
--
--           --if (temp1 = temp2 and then temp2 = temp3) then
--           --first.setOperation(0);
--           --second--.setOperation(0);
--           --third.setOperation(0);
--           --else
--           --first.setOperation(0);
--           --second.setOperation(0);
--           --third--.setOperation(0);
--           --end if;
--
--           --Put_Line("Estable consumo:"&Integer'Image(cityConsumption)&" producción:"&Integer'Image(nucleusTemp));
--
--        end if;
--        delay until tNextRelease;
--        tNextRelease := tNextRelease + tiReleaseInterval;
--     end loop;
--
--  end ControllerTask;

begin
   null;
end Main;

