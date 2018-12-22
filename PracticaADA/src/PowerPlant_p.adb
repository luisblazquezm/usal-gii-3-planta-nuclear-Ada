package body PowerPlant_p is

   protected body PowerPlant_t is

      -- Procedimiento: realiza una operaci�n sobre la temperatura del reactor
      --                dependiendo de la temperatura a la que se encuentre en ese momento.
      --                A distinguir:
      --                  > Si la temperatura < 1500  ,no se hace nada (operation_mode 0)
      --                  > Si la temperatura >= 1500 , se abre la compuerta a raz�n de 50 �C cada segundo. (operation_mode -1)
      --                  > Si la temperatura >= 1750 , se abre la compuerta por completo. (operation_mode 1)
      procedure setOperation(operation:in Integer) is
      begin

         Set_Handler(TimeoutEvent, tiTimeout, Timeout'Access);
         if (operation /= operation_mode) then
            operation_mode := operation;

            case operation_mode is
               when -1 =>
                  Put_Line("Reactor " & Integer'Image(id) & " - No hace nada");
               when 0 =>
                  Put_Line("Reactor " & Integer'Image(id) & " - Abrir compuerta");
               when 1 =>
                  Put_Line("Reactor " & Integer'Image(id) & " - PELIGRO : M�XIMO ALCANZADO 1750�C. Abrir compuerta");
               when others =>
                  null;
            end case;

            -- Simula que el actuador tarda 1 decima de segundo como m�ximo en actuar
            delay 0.1;

            tNextTime := Clock + tiEventPeriod;
            Set_Handler(OutputEvent, tNextTime, Timer'Access);
         end if;

      end setOperation;


      -- Procedimiento: tarea temporal que incrementa la temperatura cuando se produce un evento
      --                En nuestra practica, 1 vez cada 2 segundos sube la temperatura de uno
      --                de los reactores 150 �C.
      procedure Timer(event:in out Timing_Event) is
      begin
         temperature := temperature + operation_mode;
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
      --                En esta practica cada reactor imprimir� un mensaje de alerta si no
      --                recibe un mensaje de alguna de las tareas que controla un reactor pasado 3 segundos
      procedure Timeout(event:in out Timing_Event) is
      begin
         Put_Line("Alarma: Monitorizaci�n energ�a");
         Set_Handler(TimeoutEvent, tiTimeout, Timeout'Access);
      end Timeout;


   end PowerPlant_t;

end PowerPLant_p;