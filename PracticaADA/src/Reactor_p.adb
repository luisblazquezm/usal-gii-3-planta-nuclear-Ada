package body Reactor_p is

   protected body Reactor_t is

      -- Procedimiento: realiza una operación sobre la temperatura del reactor
      --                dependiendo de la temperatura a la que se encuentre en ese momento.
      --                A distinguir:
      --                  > Si la temperatura < 1500, no se hace nada (operation_mode 0)
      --                  > Si la temperatura >= 1500, se abre la compuerta a razón de 50 ºC cada segundo. (operation_mode 1)
      --                  > Si la temperatura >= 1750, se abre la compuerta por completo. (operation_mode 2)
      procedure setOperationMode(operation:in Integer) is
      begin

         -- Manejador de eventos: Lanza el evento TimeoutEvent
         --                       que ejecuta el procedimiento Timeout (de ahi el Timeout'Access)
         --                       cada tiTimeout segundos (en este caso cada 3 segundos).
         -- Este evento segun el enunciado es para controlar que cada uno de los reactores está
         -- actuando correctamente
         Set_Handler(TimeoutEvent, tiTimeout, Timeout'Access);

         if (operation /= operation_mode) then
            operation_mode := operation;

            case operation_mode is
               when 0 =>
                  Put_Line("Reactor " & Integer'Image(id) & " - No hace nada.");
               when 1 =>
                  Put_Line("Reactor " & Integer'Image(id) & " - Abrir compuerta.");
               when 2 =>
                  Put_Line("Reactor " & Integer'Image(id) & " - PELIGRO : MÁXIMO ALCANZADO 1750ºC. Abrir compuerta.");
               when others =>
                  null;
            end case;

            -- Simula que el actuador tarda 1 decima de segundo como máximo en actuar
            delay 0.1;

            -- Creo que esto es el evento que sube la temperatura de uno de los reactores
            -- 1 vez cada 2 segundos +150ºC. Pero no estoy seguro.
            tNextTime := Clock + tiEventPeriod;
            Set_Handler(OutputEvent, tNextTime, Timer'Access);
         end if;

      end setOperation;


      -- Procedimiento: tarea temporal que incrementa la temperatura cuando se produce un evento
      --                En nuestra practica, 1 vez cada 2 segundos sube la temperatura de uno
      --                de los reactores 150 ºC.
      procedure Timer(event:in out Timing_Event) is
      begin
         temperature := temperature + operation_mode; -- Esto creo que está mal, sería temperature + 150
         tNextTime := Clock + tiEventPeriod;
         Set_Handler(OutputEvent, tiEventPeriod, Timer'Access);
      exception
            when Constraint_Error => null;
      end Timer;


      -- Funcion: devuelve la temperatura del reactor
      function getTemperature return Temperature_t is
      begin
         return temperature;
      end getTemperature;


      -- Procedimiento: se establece el identificador de cada reactor
      --       [newID]: numero que se quiere establecer como nuevo ID del reactor
      procedure setID(newID:in Integer) is
      begin
        id := newID;
      end;


      -- Procedimiento: lanza un evento que tiene que ocurrir cuando salte el timeout del reactor.
      --                En esta practica cada reactor imprimirá un mensaje de alerta si no
      --                recibe un mensaje de alguna de las tareas que controla un reactor pasado 3 segundos
      procedure ReactorNotWorkingEventHandler(event:in out Timing_Event) is
      begin
         Put_Line("WARNING: Notification from reactor " & Integer'Image(id) & " not received.");
         Set_Handler(TimeoutEvent, tiTimeout, ReactorNotWorkingEventHandler'Access);
      end ReactorNotWorkingEventHandler;


   end Reactor_t;

end Reactor_p;
