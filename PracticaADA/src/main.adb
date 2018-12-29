with Reactor_p;
use Reactor_p;
with Synchronization_Barrier_p;
use Synchronization_Barrier_p;

with Ada.Real_Time; use Ada.Real_Time;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Discrete_Random;

procedure Main is

   -- Numeros aleatorios
   subtype ReactorCount_t is Integer range 1..3;
   package RandomNumber is new Ada.Numerics.Discrete_Random(ReactorCount_t);

   -- Reactors
   reactor1:aliased Reactor_t;
   reactor2:aliased Reactor_t;
   reactor3:aliased Reactor_t;

   -- To make all tasks begin at once
   number_of_tasks: constant Integer := 7;
   synchronization_barrier: Synchronization_Barrier(number_of_tasks); -- 7 = number of coordinated tasks

   -- Para inicializar el numero de los reactores
   -- PD: No, no se puede hacer fuera de una tarea porque da error, estariamos haciendo una acci�n y esta es la zona de declaraciones
   task type Init;
   task body Init is
   begin
      Put_Line("Initializing...");
      reactor1.setID(1);
      reactor2.setID(2);
      reactor3.setID(3);
   end Init;

   init: Init;

   -- Tarea coordinadora, que comprueba que el reactor funciona
   task type CoordinatorTask(reactorID: Integer) is
      entry ReactorIsAlive;
   end CoordinatorTask;
   task body CoordinatorTask is
   begin

      synchronization_barrier.

      loop
         select
            accept ReactorIsAlive do
               -- Do nothing
               null;
            end ReactorIsAlive;
         or delay 3.0; -- 3 seconds delay
            -- Timeout actions
            Put_Line("WARNING: notification from reactor " & Integer'Image(reactorID) & " not received. Possible reactor malfunction.");
         end select;
      end loop;
   end CoordinatorTask;

   -- Tareas coordinadoras
   reactor1CoordinatorTask: CoordinatorTask(reactor1.getID);
   reactor2CoordinatorTask: CoordinatorTask(reactor2.getID);
   reactor3CoordinatorTask: CoordinatorTask(reactor3.getID);

   -- Tarea controladora, que actua en funci�n de la temperatura del nucleo
   task type ControllerTask(reactorID: Integer; reactorTemperature: Temperature_t); -- He probado a pasar la referencia de cada reactor con un access pero no me va -.-
   task body ControllerTask is
      tNextRelease: Time;
      tiReleaseInterval:constant Time_Span:=Milliseconds(2000);

      temperature:Temperature_t := reactorTemperature;
      ID:Integer := reactorID;

   begin

      synchronizationBarrier.Wait;

      -- Empezamos a contar los 2 segundos de muestreo
      tNextRelease := Clock + tiReleaseInterval;

      -- Filtramos los casos seg�n la temperatura a la que se encuentre el nucleo
      loop

         -- CASO 1: temperatura es superior a (1500�C)
         if (temperature >= 1500 and then temperature <= 1750) then
            -- Se abre una compuerta. Baja la temperratura 50 �C
            -- Compuerta se mantiene abierta mientras la temperatura sea superior a los 1500�
            Put_Line("WARNING: reactor " & Integer'Image(reactorID) & ": temperature over 1500�C.");
            case ID is
               when 1 => reactor1.setOperationMode(1);
               when 2 => reactor2.setOperationMode(1);
               when 3 => reactor3.setOperationMode(1);
               when others =>  null;
            end case;

         -- CASO 2: temperatura es superior a 1750�C
         elsif (temperature > 1750) then
            -- Se mantiene la compuerta abierta
            Put_Line("WARNING: reactor " & Integer'Image(reactorID) & ": temperature over 1750�C.");
            case ID is
               when 1 => reactor1.setOperationMode(2);
               when 2 => reactor2.setOperationMode(2);
               when 3 => reactor3.setOperationMode(2);
               when others =>null;
            end case;

         -- CASO 3: temperatura inferior a 1500�C
         else
            -- No se hace nada
            Put_Line("Reactor " & Integer'Image(reactorID) & " is stable.");
            --null;
         end if;

         -- Put_Line("�Estas vivo reactor " & Integer'Image(ID) & " ?");
         -- Manda un mensaje al coordinador para indicar que est� vivo cuando acaba de muestrear
         case ID is
            when 1 => reactor1CoordinatorTask.ReactorIsAlive;
            when 2 => reactor2CoordinatorTask.ReactorIsAlive;
            when 3 => reactor3CoordinatorTask.ReactorIsAlive;
            when others => null;
         end case;

         delay until tNextRelease;
         tNextRelease := tNextRelease + tiReleaseInterval;
      end loop;

   end ControllerTask;

   -- Tareas controladoras
   reactor1ControllerTask:ControllerTask(reactor1.getID, reactor1.getTemperature);
   reactor2ControllerTask:ControllerTask(reactor2.getID, reactor2.getTemperature);
   reactor3ControllerTask:ControllerTask(reactor3.getID, reactor3.getTemperature);

   -- Tarea de variaci�n de la temperatura en el reactor
   task type varyTemperatureTask;
   task body varyTemperatureTask is
      randomNumberGeneratorSeed: RandomNumber.Generator;
      tNextRelease: Time;
      numReactor: ReactorCount_t;
      tiReleaseInterval:constant Time_Span := Milliseconds(2000);
begin

      synchronizationBarrier.Wait;

      RandomNumber.Reset(randomNumberGeneratorSeed);
      numReactor := RandomNumber.Random(randomNumberGeneratorSeed);

      -- Sube la temperatura cada 2 segundos
      tNextRelease := Clock + tiReleaseInterval;

      loop
         -- Seleccionar un reactor al azar, y subir su temperatura 150�C
         case numReactor is
            when 1 =>
               reactor1.modifyTemperature(150);
            when 2 =>
               reactor1.modifyTemperature(150);
            when 3 =>
               reactor1.modifyTemperature(150);
            when others =>
               null;
         end case;

         delay until tNextRelease;
         tNextRelease := tNextRelease + tiReleaseInterval;
      end loop;

   end varyTemperatureTask;

   -- Objeto tarea de variaci�n de la temperatura
   varyTemperatureTask: varyTemperatureTask;

begin
   null;
end Main;





