with System;
with Ada.Real_Time; use Ada.Real_Time;
with Ada.Real_Time.Timing_Events; use Ada.Real_Time.Timing_Events;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Calendar.Formatting;

package Reactor_Package is

   -- Rango de valores que podrá tomar los reactores (entre 0 y 2000)
   -- Aunque ninguno puede superar los 1750ºC
   -- A lo mejor se podria variar el rango.
   subtype Temperature_t is Integer;

   protected type Reactor is

      procedure setOperationMode(operation:in Integer);
      procedure setID(newID:in Integer);
      procedure modifyTemperature(temp:in Integer);

      procedure OpenGate;
      procedure GateTimer(event: in out Ada.Real_Time.Timing_Events.Timing_Event);
      procedure CloseGate;

      function getTemperature return Temperature_t;
      function getID return Integer;

   private
      -- To simulate gate opening
      -- Period = Needed_period - max_jitter (1 second - 0.1 seconds = 0.9 seconds)
      openSluiceGate_Period: Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(900);
      openSluiceGateEvent: Ada.Real_Time.Timing_Events.Timing_Event;
      OpenSluiceGate_NextTime: Ada.Real_Time.Time;

      -- Temperature decrement
      decrement: Temperature_t := 50;

      -- Temperatura inicial de cada reactor
      temperature:Temperature_t:=1450;

      -- Por defecto está a 0, que es no hacer NADA.
      operation_mode:Integer:=0;

      -- Nº de id guardado de cada reactor
      id:Integer;

   end Reactor;

end Reactor_Package;
