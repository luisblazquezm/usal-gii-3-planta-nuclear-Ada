with PowerPlant_p;
with Ada.Real_Time;
with Ada.Text_IO;

use Ada.Real_Time;
use Ada.Text_IO;


use PowerPlant_p;
with Ada.Numerics.Discrete_Random;


procedure Main is

   subtype ConsumptionVariance_t is Integer range -3..3;
   package RNG is new Ada.Numerics.Discrete_Random(ConsumptionVariance_t);

   subtype PowerConsumption_t is Integer range 15..90;
   subtype PlantOutput_t is Integer range 0..30;

   protected type City_t is
      procedure varyConsumption;
      function getConsumption return PowerConsumption_t;
   private
      consumption:PowerConsumption_t:=35;
   end City_t;

   protected body City_t is

      procedure varyConsumption is
         variance:ConsumptionVariance_t;
         seed:RNG.Generator;
      begin
         RNG.Reset(seed);
         variance := RNG.Random(seed);
         Consumption := Consumption + variance;
      exception
            when Constraint_Error => null;
      end;

      function getConsumption return PowerConsumption_t is
      begin
         return consumption;
      end getConsumption;

   end City_t;

   city:City_t;

   plant1: aliased PowerPlant_t;
   plant2: aliased PowerPlant_t;
   plant3: aliased PowerPlant_t;

   task type tskVaryPowerConsumption;
   task body tskVaryPowerConsumption is

      tNextRelease: Time;
      tiReleaseInterval:constant Time_Span:=Milliseconds(1000);


   begin

      tNextRelease := Clock + tiReleaseInterval;
      loop
         city.varyConsumption;
         delay until tNextRelease;
         tNextRelease := tNextRelease + tiReleaseInterval;
      end loop;

   end tskVaryPowerConsumption;

   PowerVariance: tskVaryPowerConsumption;



   procedure getTotalOutput(out1:out Output_t; out2:out Output_t; out3:out Output_t) is
      task type p1;
      task body p1 is
      begin
         out1 := plant1.getOutput;
      end p1;
      task type p2;
      task body p2 is
      begin
         out2 := plant1.getOutput;
      end p2;
      task type p3;
      task body p3 is
      begin
         out3 := plant3.getOutput;
      end p3;

      taskp1:p1;
      taskp2:p2;
      taskp3:p3;
   begin
   	   null;
   end getTotalOutput;


   task type tskMonitorConsumption;
   task body tskMonitorConsumption is
      tNextRelease: Time;
      tiReleaseInterval:constant Time_Span:=Milliseconds(200);



      cityConsumption:PowerConsumption_t;



      out1:Output_t;
      out2:Output_t;
      out3:Output_t;

      output:Integer;
      diff:Integer;

      type plant_ptr is access all PowerPlant_t;

      first:plant_ptr:=plant1'access;
      second:plant_ptr:=plant2'Access;
      third:plant_ptr:=plant3'Access;

   begin
      plant1.setID(1);
      plant2.setID(2);
      plant3.setID(3);
      tNextRelease := Clock + tiReleaseInterval;
      loop
         --delay 6.0;
         getTotalOutput(out1, out2, out3);
         delay 0.1;
         cityConsumption := City.getConsumption;
         output := out1 + out2 + out3;
         if (out3 >= out1 and then out3 >= out2) then
            first := plant3'access;
            if (out2 > out1) then
               third := plant1'Access;
            else
               second := plant1'Access;
               third := plant2'Access;
            end if;
         elsif (out2 > out3 and then out2 > out1) then
            first := plant2'access;
            if (out3 >= out1) then
               second := plant3'Access;
               third := plant1'Access;
            else
               second := plant1'Access;
            end if;
         elsif (out3 >= out2) then
            second:=plant3'Access;
            third:=plant2'Access;
         end if;



      	 if ((Float(cityConsumption) - Float(output))/Float(cityConsumption) > 0.05) then
            --Put_Line("PELIGRO BAJADA consumo:"&Integer'Image(cityConsumption)&" producción:"&Integer'Image(output));
            diff := cityConsumption-output;
            third.setOperation(1);
            if (diff >= 2) then second.setOperation(1); else second.setOperation(0); end if;
            if (diff >= 3) then first.setOperation(1); else first.setOperation(0); end if;
            Put_Line("PELIGRO BAJADA consumo:"&Integer'Image(cityConsumption)&" producción:"&Integer'Image(output));

      	 elsif ((Float(cityConsumption) - Float(output))/Float(cityConsumption) < -0.05) then
            --Put_Line("PELIGRO SOBRECARGA consumo:"&Integer'Image(cityConsumption)&" producción:"&Integer'Image(output)&"= "&Integer'Image(out1)&" + "&Integer'Image(out2)&" + "&Integer'Image(out3));
            diff := output - cityConsumption;
            first.setOperation(-1);
            if (diff >= 2) then second.setOperation(-1); else second.setOperation(0); end if;
            if (diff >= 3) then third.setOperation(-1); else third.setOperation(0); end if;
            Put_Line("PELIGRO SOBRECARGA consumo:"&Integer'Image(cityConsumption)&" producción:"&Integer'Image(output));

         else
            --Put_Line("Estable consumo:"&Integer'Image(cityConsumption)&" producción:"&Integer'Image(output)&"= "&Integer'Image(out1)&" + "&Integer'Image(out2)&" + "&Integer'Image(out3));
            if (out1 = out2 and then out2 = out3) then
               first.setOperation(0);
               second.setOperation(0);
               third.setOperation(0);
            else
               first.setOperation(0);
               second.setOperation(0);
               third.setOperation(0);
            end if;

            Put_Line("Estable consumo:"&Integer'Image(cityConsumption)&" producción:"&Integer'Image(output));

         end if;
         delay until tNextRelease;
         tNextRelease := tNextRelease + tiReleaseInterval;
      end loop;

   end tskMonitorConsumption;

   PowerMonitoring:tskMonitorConsumption;


begin
null;
end Main;

