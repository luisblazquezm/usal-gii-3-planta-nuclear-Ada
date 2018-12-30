with System;
with Ada.Real_Time; use Ada.Real_Time;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
with Ada.Real_Time.Timing_Events; use Ada.Real_Time.Timing_Events;
with Ada.Calendar.Formatting;

with Reactor_Package; use Reactor_Package;

procedure Main is

   -- Numeros aleatorios
   subtype ReactorCount_t is Integer range 1..3;
   package RandomNumber is new Ada.Numerics.Discrete_Random(ReactorCount_t);

   -- Reactors
   reactor1: aliased Reactor;
   reactor2: aliased Reactor;
   reactor3: aliased Reactor;

   -- Para inicializar el numero de los reactores
   -- PD: No, no se puede hacer fuera de una tarea porque da error, estariamos haciendo una acción y esta es la zona de declaraciones
   -- PPD: Pero se podría hacer en el begin de Nuclear_Plant si creamos las tareas después \_('-')_/
   task type InitTask;
   task body InitTask is
   begin
      Put_Line("Initializing...");

      reactor1.setID(1);
      reactor2.setID(2);
      reactor3.setID(3);
   end InitTask;

   init: InitTask;

   -- Tarea coordinadora, que comprueba que el reactor funciona
   -- Por que cojones cada vez que abro el bloque del type en el IDE aparece aqui debajo 'entry ReactorIsAlive';
   task type CoordinatorTask(reactorID: Integer) is
      entry ReactorIsAlive;
      entry Launch; -- Para que no empiece a ejecutarse antes de que su tarea de control exista
   end CoordinatorTask;
   task body CoordinatorTask is
   begin
      -- To wait for correspondent controller task
      accept Launch  do
         null;
      end Launch;

      loop
         select
            accept ReactorIsAlive do
               -- Do nothing
               null;
            end ReactorIsAlive;
         or delay 3.0; -- 3 seconds delay
            -- Timeout actions
            Put_Line("WARNING: notification from reactor" & Integer'Image(reactorID) & " not received. Possible reactor malfunction.");
         end select;
      end loop;
   end CoordinatorTask;

   -- Tareas coordinadoras
   reactor1CoordinatorTask:aliased CoordinatorTask(reactor1.getID);
   reactor2CoordinatorTask:aliased CoordinatorTask(reactor2.getID);
   reactor3CoordinatorTask:aliased CoordinatorTask(reactor3.getID);

   -- Tarea controladora, que actua en función de la temperatura del nucleo
   task type ControllerTask(reactor_access:access Reactor; coordinator_access:access CoordinatorTask); ----------------------------------------------------------------------------------------- TODO
                                                            -- La gracia está en pasar el reactor y el coordinador por referencia,
                                                            -- para evitar hacer esas sentencias case-when (imagina que fueran 1200 reactores y no 3 xd)
                                                            -- Así que falta por modificar eso y ver que sigue funcionando.

   -- This entry can be added to execute terminate for some reactor and check
   -- that the coordinator task works properly. Check below.
   task body ControllerTask is

      tNextRelease: Time;
      tiReleaseInterval:constant Time_Span:=Milliseconds(2000);
      temperature: Temperature_t;
      reactorID: Integer := 0;

      --coordinator_access := new CoordinatorTask;

   begin

      reactorID := reactor_access.getID;

      coordinator_access.Launch;
--        case reactorID is
--           when 1 => reactor1CoordinatorTask.Launch;
--           when 2 => reactor2CoordinatorTask.Launch;
--           when 3 => reactor3CoordinatorTask.Launch;
--           when others =>null;
--        end case;

      -- Empezamos a contar los 2 segundos de muestreo
      tNextRelease := Clock + tiReleaseInterval;

      -- Filtramos los casos según la temperatura a la que se encuentre el nucleo
      loop

         temperature := reactor_access.getTemperature;

         -- CASO 1: temperatura es superior a (1500ºC)
         if (temperature >= 1500 and then temperature <= 1750) then
            -- Se abre una compuerta. Baja la temperratura 50 ºC
            -- Compuerta se mantiene abierta mientras la temperatura sea superior a los 1500º
            Put_Line("WARNING: reactor " & Integer'Image(reactorID) & ": temperature over 1500ºC.");
            reactor_access.setOperationMode(1);
--              case reactorID is
--                 when 1 => reactor1.setOperationMode(1);
--                 when 2 => reactor2.setOperationMode(1);
--                 when 3 => reactor3.setOperationMode(1);
--                 when others =>  null;
--              end case;

            -- CASO 2: temperatura es superior a 1750ºC
         elsif (temperature > 1750) then
            -- Se mantiene la compuerta abierta
            Put_Line("WARNING: reactor " & Integer'Image(reactorID) & ": temperature over 1750ºC.");
            reactor_access.setOperationMode(2);
--              case reactorID is
--                 when 1 => reactor1.setOperationMode(2);
--                 when 2 => reactor2.setOperationMode(2);
--                 when 3 => reactor3.setOperationMode(2);
--                 when others =>null;
--              end case;

         -- CASO 3: temperatura inferior a 1500ºC
         else
            -- No se hace nada
            Put_Line("Reactor " & Integer'Image(reactorID) & " is stable.");
            reactor_access.setOperationMode(0);
--              case reactorID is
--                 when 1 => reactor1.setOperationMode(0);
--                 when 2 => reactor2.setOperationMode(0);
--                 when 3 => reactor3.setOperationMode(0);
--                 when others =>null;
--              end case;
            --null;
         end if;

         -- Manda un mensaje al coordinador para indicar que está vivo cuando acaba de muestrear
         coordinator_access.ReactorIsAlive;
--           case reactorID is
--              when 1 => reactor1CoordinatorTask.ReactorIsAlive;
--              when 2 => reactor2CoordinatorTask.ReactorIsAlive;
--              when 3 => reactor3CoordinatorTask.ReactorIsAlive;
--              when others => null;
--           end case;

         delay until tNextRelease;
         tNextRelease := tNextRelease + tiReleaseInterval;
      end loop;

   end ControllerTask;

   -- Tareas controladoras
   reactor1ControllerTask:ControllerTask(reactor1'Access, reactor1CoordinatorTask'Access);
   reactor2ControllerTask:ControllerTask(reactor2'Access, reactor2CoordinatorTask'Access);
   reactor3ControllerTask:ControllerTask(reactor3'Access, reactor3CoordinatorTask'Access);

   -- Tarea de variación de la temperatura en el reactor
   task type varyTemperatureTask;
   task body varyTemperatureTask is
      randomNumberGeneratorSeed: RandomNumber.Generator;
      tNextRelease: Time;
      numReactor: ReactorCount_t;
      tiReleaseInterval:constant Time_Span := Milliseconds(2000);
   begin

      RandomNumber.Reset(randomNumberGeneratorSeed);
      -- Sube la temperatura cada 2 segundos
      tNextRelease := Clock + tiReleaseInterval;

      loop
         numReactor := RandomNumber.Random(randomNumberGeneratorSeed);
         -- Seleccionar un reactor al azar, y subir su temperatura 150ºC
         case numReactor is
            when 1 =>
               reactor1.modifyTemperature(150);
            when 2 =>
               reactor2.modifyTemperature(150);
            when 3 =>
               reactor3.modifyTemperature(150);
            when others =>
               null;
         end case;

         delay until tNextRelease;
         tNextRelease := tNextRelease + tiReleaseInterval;
      end loop;

   end varyTemperatureTask;

   -- Objeto tarea de variación de la temperatura
   varyTemperature: varyTemperatureTask;

begin
   -- También podríamos instanciar todas las tareas dentro del begin
   null;
end Main;
