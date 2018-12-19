with Ada.Real_Time;
with Ada.Real_Time.Timing_Events;
with Ada.Text_IO;

use Ada.Real_Time;
use Ada.Real_Time.Timing_Events;
use Ada.Text_IO;

with Ada.Calendar.Formatting;

package PowerPlant_p is

   subtype Output_t is Integer range 0..30;

   protected type PowerPlant_t is

      procedure setOperation(operation:in Integer);
      procedure Timer(event:in out Timing_Event);
      procedure Timeout(event:in out Timing_Event);
      function getOutput return Output_t;

      procedure setID(newID:in Integer);

   private

      tiTimeout:Time_Span:=Milliseconds(3000);
      tNextTime:Time;
      output:Output_t:=15;
      operation_mode:Integer:=0;
      tiEventPeriod:Time_Span:=Milliseconds(1000);
      OutputEvent:Timing_Event;
      TimeoutEvent:Timing_Event;
      id:Integer;

   end PowerPlant_t;

end PowerPlant_p;
