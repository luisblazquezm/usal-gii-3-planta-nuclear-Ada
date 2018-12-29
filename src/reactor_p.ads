with System;
with Ada.Real_Time; use Ada.Real_Time;
with Ada.Real_Time.Timing_Events; use Ada.Real_Time.Timing_Events;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Calendar.Formatting;

package Reactor_Package is
   -- Rango de valores que podrá tomar los reactores (entre 0 y 2000)
   -- Aunque ninguno puede superar los 1750ºC
   -- A lo mejor se podria variar el rango.
   subtype Temperature_t is Integer range 0..2000;

   protected type Reactor is

      procedure setOperationMode(operation:in Integer);
      procedure ActuatorEventHandler(event:in out Timing_Event);
      procedure setID(newID:in Integer);
      procedure modifyTemperature(temp:in Integer);

      function getTemperature return Temperature_t;
      function getID return Integer;

   private
      -- Periodo de tiempo del evento (3 segundos)
      tiTimeout:Time_Span:=Milliseconds(3000);
      tNextTime:Time;

      -- Temperatura inicial de cada reactor
      temperature:Temperature_t:=1450;

      -- Por defecto está a 0, que es no hacer NADA.
      operation_mode:Integer:=0;

      -- Periodo de tiempo del evento (1 segundo)
      tiEventPeriod:Time_Span:=Milliseconds(1000);

      -- Eventos de Tiempo
      OutputEvent:Timing_Event;
      TimeoutEvent:Timing_Event;

      -- Nº de id guardado de cada reactor
      id:Integer;
   end Reactor;

end Reactor_Package;
