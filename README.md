# Atomic-Structure-Calculations-Non-Relativistic-
Based upon the Herman-Skillman code for calculating non-relativistic Hartree-Fock-Slater wavefunctions. 

This repository contains the input files necessary to use the code in the main branch. 

Here is an example of an input file for Carbon

CONT     POT     RAD

CARBON

   0 0.001  0.00001 441   1  50   0   0.000000000   1.000000000   1.00000
 1.00000 .99384 .98748 .98095 .97428 .96750 .96064 .95371 .94674 .93974
  .93273 .91873 .90483 .89111 .87760 .86436 .85141 .83876 .82642 .81440
  .80269 .78020 .75887 .73860 .71929 .70084 .68315 .66616 .64979 .63400
  .61874 .58976 .56278 .53786 .51509 .49448 .47596 .45930 .44420 .43038
  .41755 .39410 .37273 .35292 .33441 .31711 .30095 .28586 .27180 .25871
  .24652 .22462 .20558 .18896 .17441 .16667 .16667 .16667 .16667 .16667
  .16667 .16667 .16667 .16667 .16667 .16667 .16667 .16667 .16667 .16667
  .16667 .16667 .16667 .16667 .16667 .16667 .16667 .16667 .16667 .16667
  .16667 .16667 .16667 .16667 .16667 .16667 .16667 .16667 .16667 .16667
  .16667 .16667 .16667 .16667 .16667 .16667 .16667 .16667 .16667 .16667
  .16667 .16667 .16667 .16667 .16667 .16667 .16667 .16667 .16667 .16667
  6    1   2  0.000000
 100  2.000000   -21.3780
 200  2.000000    -1.2895
 210  2.000000    -0.6603
  -1
  
  
  If you want to make your own inputs.
  
  The second line is the name of the element. That you can change. 
  The next few lines are the potential. Those are best left unchanged. 
  
  The line containing:  6    1   2  0.000000 must be changed to make a new element.
  
  The first number in the line is the the atomic number of the element Z. In this case, Z=6.
  The second number is the number of unfilled orbitals, 1 for Carbon.
  The third number is the number of filled orbitals, 2 for Carbon. 
  The fourth number is the ionicity, which is 0.000000 for neutral atoms.
  
  The next lines specify the orbitals for the element. 
  
  nlm, the number of electrons in the shell, and the guess of the energy in Hartrees.
 
