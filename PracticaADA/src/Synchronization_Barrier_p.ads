package Synchronization_Barrier_p is

   protected type Synchronization_Barrier(tasks: Integer) is
      entry wait;
      procedure using;
   private
      counter: Integer := 0;
      number_of_tasks: Integer := tasks;
   end Synchronization_Barrier;

end Synchronization_Barrier_p;
