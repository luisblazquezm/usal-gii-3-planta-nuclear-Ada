with Ada.Real_Time;
with Ada.Real_Time.Timing_Events;
with Ada.Text_IO;

use Ada.Real_Time;
use Ada.Real_Time.Timing_Events;
use Ada.Text_IO;

with Ada.Calendar.Formatting;

package PowerPlant_p is

   -- Rango de valores que podr� tomar los reactores (entre 0 y 2000)
   -- Aunque ninguno puede superar los 1750�C
   subtype Temperature_t is Integer range 0..2000;

   protected type PowerPlant_t is

      procedure setOperation(operation:in Integer);
      procedure Timer(event:in out Timing_Event);
      procedure Timeout(event:in out Timing_Event);
      procedure setID(newID:in Integer);

      function getTemperature return Temperature_t;

   private

      tiTimeout:Time_Span:=Milliseconds(3000);
      tNextTime:Time;
      temperature:Temperature_t:=1450;
      operation_mode:Integer:=0; -- Por defecto est� a 0, que es no hacer NADA
      tiEventPeriod:Time_Span:=Milliseconds(1000);
      OutputEvent:Timing_Event;
      TimeoutEvent:Timing_Event;
      id:Integer;

   end PowerPlant_t;

end PowerPlant_p;
