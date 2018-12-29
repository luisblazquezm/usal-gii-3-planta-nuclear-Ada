package body reactor_p is

   protected body Reactor is

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
         Set_Handler(TimeoutEvent, tiTimeout, ReactorNotWorkingEventHandler'Access);

         if (operation /= operation_mode) then
            operation_mode := operation;

            case operation_mode is
               when 0 =>
                  Put_Line("Reactor " & Integer'Image(id) & " - Nothing.");
               when 1 =>
                  Put_Line("Reactor " & Integer'Image(id) & " - Opening gate.");

                  tNextTime := Clock + tiEventPeriod;
                  Set_Handler(OutputEvent, tNextTime, ActuatorEventHandler'Access);
               when 2 =>
                  Put_Line("Reactor " & Integer'Image(id) & " - WARNING : MAXIMUM TEMPERATURE 1750ºC REACHED . Opening gate.");

                  while temperature < 1500 loop
                     tNextTime := Clock + tiEventPeriod;
                     Set_Handler(OutputEvent, tNextTime, ActuatorEventHandler'Access);
                  end loop;
               when others =>
                  null;
            end case;

            -- Simula que el actuador tarda 1 decima de segundo como máximo en actuar
            delay 0.1;

         end if;

      end setOperationMode;


      -- Procedimiento: tarea temporal que incrementa la temperatura cuando se produce un evento
      --                En nuestra practica, 1 vez cada 2 segundos sube la temperatura de uno
      --                de los reactores 150 ºC.
      procedure ActuatorEventHandler(event:in out Timing_Event) is
      begin
         temperature := temperature - 50;
         Put_Line(" ");
         Put_Line("Reactor " & Integer'Image(id) & " Temperature : " & Integer'Image(temperature));
         Put_Line(" ");

         --tNextTime := Clock + tiEventPeriod;
         --Set_Handler(OutputEvent, tiEventPeriod, ActuatorEventHandler'Access);
      exception
            when Constraint_Error => null;
      end ActuatorEventHandler;


      -- Funcion: devuelve la temperatura del reactor
      function getTemperature return Temperature_t is
      begin
         return temperature;
      end getTemperature;

      -- Procedimiento: incrementa o disminuye la temperatura del reactor 'temp' grados.
      procedure modifyTemperature(temp:in Integer) is
      begin
         temperature := temperature + temp;
      end modifyTemperature;

      -- Funcion: devuelve el ID del reactor
      function getID return Integer is
      begin
         return id;
      end getID;

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


   end Reactor;

end reactor_p;
