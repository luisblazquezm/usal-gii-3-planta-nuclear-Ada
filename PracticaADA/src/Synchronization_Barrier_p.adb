package body Synchronization_Barrier_p is

   protected body Synchronization_Barrier is

      entry wait
        when counter = number_of_tasks is
      begin
         counter := 0;
      end wait;

      procedure using is
      begin
         counter := counter + 1;
      end using;

   end Synchronization_Barrier;

end Synchronization_Barrier_p;