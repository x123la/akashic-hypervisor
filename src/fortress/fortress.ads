with Interfaces.C; use Interfaces.C;
with System;

package Fortress is
   --  Check an EPT PML4 table for security violations
   function Verify_Security (PML4_Addr : unsigned_long) return int
     with Export, Convention => C, External_Name => "fortress_verify_security";
end Fortress;
