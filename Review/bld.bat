@Echo off

cd Review
call _bld %1 %2 %3
cd ..

cd ReviewGFL
call _bld %1 %2 %3
cd ..

cd ReviewWIC
call _bld %1 %2 %3
cd ..

cd ReviewVideo
call _bld %1 %2 %3
cd ..

cd ReviewSVG
call _bld %1 %2 %3
cd ..


set PrjName=Review
