package body PowerPlant_p is

   protected body PowerPlant_t is

      procedure setOperation(operation:in Integer) is
      begin
                  Set_Handler(TimeoutEvent, tiTimeout, Timeout'Access);
         if (operation /= operation_mode) then
            operation_mode := operation;

            case operation_mode is
               when -1 =>
                  Put_Line("BAJO "&Integer'Image(id));
               when 0 =>
                  Put_Line("PARO "&Integer'Image(id));
               when 1 =>
                  Put_Line("SUBO "&Integer'Image(id));
               when others =>
                  null;
            end case;

            delay 0.1;

            tNextTime := Clock + tiEventPeriod;
            Set_Handler(OutputEvent, tNextTime, Timer'Access);
         end if;
      end setOperation;

      procedure Timer(event:in out Timing_Event) is
      begin
         output := output + operation_mode;
         tNextTime := Clock + tiEventPeriod;
         Set_Handler(OutputEvent, tiEventPeriod, Timer'Access);
      exception
            when Constraint_Error => null;
      end Timer;

      function getOutput return Output_t is
      begin
         return output;
      end getOutput;

      procedure setID(newID:in Integer) is
      begin
        id := newID;
      end;

      procedure Timeout(event:in out Timing_Event) is
      begin
         Put_Line("Alarma: Monitorización energía");
         Set_Handler(TimeoutEvent, tiTimeout, Timeout'Access);
      end Timeout;


   end PowerPlant_t;

end PowerPLant_p;
