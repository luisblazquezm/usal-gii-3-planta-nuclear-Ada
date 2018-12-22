with PowerPlant_p;
with Ada.Real_Time;
with Ada.Text_IO;

use Ada.Real_Time;
use Ada.Text_IO;


use PowerPlant_p;
with Ada.Numerics.Discrete_Random;


procedure Main is

   -- Numeros aleatorios
   subtype ConsumptionVariance_t is Integer range -3..3;
   package RNG is new Ada.Numerics.Discrete_Random(ConsumptionVariance_t);

   subtype PowerConsumption_t is Integer range 15..90;
   subtype PlantOutput_t is Integer range 0..30;

   -- 3 reactores nucleares
   plant1: aliased PowerPlant_t;
   plant2: aliased PowerPlant_t;
   plant3: aliased PowerPlant_t;

   -- Tarea de variación de la temperatura en el reactor
   task type tskVaryTemperature;
   task body tskVaryTemperature is
      tNextRelease: Time;
      tiReleaseInterval:constant Time_Span:=Milliseconds(1000);
   begin

      tNextRelease := Clock + tiReleaseInterval;
      loop
         --#city.varyConsumption;
         delay until tNextRelease;
         tNextRelease := tNextRelease + tiReleaseInterval;
      end loop;

   end tskVaryTemperature;

   -- Objeto tarea de variación de la temperatura
   TempVariance: tskVaryTemperature;


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
   task type tskMonitorConsumption;
   task body tskMonitorConsumption is
      tNextRelease: Time;
      tiReleaseInterval:constant Time_Span:=Milliseconds(200);

      -- Temperatura de los 3 reactores
      temp1:Temperature_t;
      temp2:Temperature_t;
      temp3:Temperature_t;

      -- Temperatura del nucleo del reactor (la suma de la temp. de los tres reactores)
      nucleusTemp:Integer;
      diff:Integer;

      type plant_ptr is access all PowerPlant_t;

      -- 3 reactores nucleares / 1 tarea por reactor nuclear
      first:plant_ptr:=plant1'access;
      second:plant_ptr:=plant2'Access;
      third:plant_ptr:=plant3'Access;

   begin
      -- Se les asigna un id a cada reactor. Sirve sobre todo para identificarlos.
      plant1.setID(1);
      plant2.setID(2);
      plant3.setID(3);

      tNextRelease := Clock + tiReleaseInterval;

      loop

         getTotalTemperature(temp1, temp2, temp3);

         --Delay de 1 segundo para simular la lectura de la temperatura
         delay 0.1;
         nucleusTemp := temp1 + temp2 + temp3;
         --if (temp3 >= temp1 and then temp3 >= temp2) then
            --first := plant3'access;
            --if (temp2 > temp1) then
               --third := plant1'Access;
            --else
               --second := plant1'Access;
               --third := plant2'Access;
            --end if;
         --elsif (temp2 > out3 and then temp2 > temp1) then
            --first:= plant2'access;
            --if (temp3 >= temp1) then
               --second := plant3'Access;
               --third:= plant1'Access;
            --else
               --second:= plant1'Access;
            --end if;
         --elsif (temp3 >= temp2) then
            --second:=plant3'Access;
            --third:=plant2'Access;
         end if;


         -- CASO 1: temperatura es superior a (1500ºC)
      	 if (Float(nucleusTemp) >= 1500 and then Float(nucleusTemp) <= 1750) then

            --diff := cityConsumption-nucleusTemp;
            --third--.setOperation(1);
            --if (diff >= 2) then second.setOperation(1); else second.setOperation(0); end if;
            --if (diff >= 3) then first.setOperation(1); else first.setOperation(0); end if;
            --Put_Line("PELIGRO BAJADA consumo:"&Integer'Image(cityConsumption)&" producción:"&Integer'Image(nucleusTemp));

         -- CASO 2: temperatura es superior a 1750ºC
      	 elsif (Float(nucleusTemp) > 1750) then

            --diff := nucleusTemp - cityConsumption;
            --first--.setOperation(-1);
            --if (diff >= 2) then second.setOperation(-1); else second.setOperation(0); end if;
            --if (diff >= 3) then third.setOperation(-1); else third.setOperation(0); end if;
            --Put_Line("PELIGRO SOBRECARGA consumo:"&Integer'Image(cityConsumption)&" producción:"&Integer'Image(nucleusTemp));

         -- CASO 3: temperatura inferior a 1500ºC
         else

            --if (temp1 = temp2 and then temp2 = temp3) then
               --first.setOperation(0);
               --second--.setOperation(0);
               --third.setOperation(0);
            --else
               --first.setOperation(0);
               --second.setOperation(0);
               --third--.setOperation(0);
            --end if;

            --Put_Line("Estable consumo:"&Integer'Image(cityConsumption)&" producción:"&Integer'Image(nucleusTemp));

         end if;
         delay until tNextRelease;
         tNextRelease := tNextRelease + tiReleaseInterval;
      end loop;

   end tskMonitorConsumption;

   PowerMonitoring:tskMonitorConsumption;

begin
   null;
end Main;

