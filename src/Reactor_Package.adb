package body Reactor_Package is

   protected body Reactor is

      procedure OpenGate is
      begin
         OpenSluiceGate_NextTime := Clock + openSluiceGate_Period;
         Ada.Real_Time.Timing_Events.Set_Handler(openSluiceGateEvent, OpenSluiceGate_NextTime, GateTimer'Access);
      end OpenGate;

      procedure CloseGate is
      begin
         Ada.Real_Time.Timing_Events.Set_Handler(openSluiceGateEvent, OpenSluiceGate_NextTime, null);
      end CloseGate;

      procedure GateTimer(event: in out Ada.Real_Time.Timing_Events.Timing_Event) is
      begin
         temperature := temperature - decrement;
         OpenSluiceGate_NextTime := Clock + openSluiceGate_Period;
         Ada.Real_Time.Timing_Events.Set_Handler(openSluiceGateEvent, OpenSluiceGate_NextTime, GateTimer'Access);
      end GateTimer;

      -- Procedimiento: realiza una operación sobre la temperatura del reactor
      --                dependiendo de la temperatura a la que se encuentre en ese momento.
      --                A distinguir:
      --                  > Si la temperatura < 1500, no se hace nada (operation_mode 0)
      --                  > Si la temperatura >= 1500, se abre la compuerta a razón de 50 ºC cada segundo. (operation_mode 1)
      --                  > Si la temperatura >= 1750, se abre la compuerta por completo. (operation_mode 2)
      procedure setOperationMode(operation:in Integer) is
      begin

         if (operation /= operation_mode) then

            operation_mode := operation;

            case operation_mode is
               when 0 =>
                  -- Put_Line("Reactor " & Integer'Image(id) & " - Everything working normally.");
                  CloseGate;
               when 1 =>
                  -- Put_Line("Reactor " & Integer'Image(id) & " - Opening gate.");
                  OpenGate;
               when 2 =>
                  Put_Line("Reactor " & Integer'Image(id) & " - Gate will remain open.");
                  OpenGate;
               when others =>
                  null;
            end case;

         end if;

      end setOperationMode;

      -- Funcion: devuelve la temperatura del reactor
      function getTemperature return Temperature_t is
      begin
         return temperature;
      end getTemperature;

      -- Procedimiento: incrementa o disminuye la temperatura del reactor 'temp' grados.
      procedure modifyTemperature(temp:in Integer) is
      begin
         -- DEBUG
         -- Put_Line("Temperature " & Integer'Image(id) & " is " & Integer'Image(temperature));
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

   end Reactor;


end Reactor_Package;
