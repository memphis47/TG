testeFolder=$1
while [ $testeFolder -le $2 ]
do
	cp ./Teste/Teste$testeFolder/*.c ./cLupaInput/ &&
	cd cLupaInput &&
	rm -r prog1.bin prog.bin data.bin data1.bin 2>&1 && 
	rm -r ../prog1.bin ../prog.bin ../data.bin ../data1.bin 2>&1 && 
	../bin/compile.sh core1.c && 
	cp data.bin data1.bin && cp prog.bin prog1.bin && 
	../bin/compile.sh core0.c && 
	cp *.bin ../ &&
	cd .. &&

	n=$3

	# continue until $n equals 256
	mkdir -p "./result/teste$testeFolder/" &&
	while [ $n -le $4 ]
	do
		filename100="./result/teste$testeFolder/result_t100_b$n" 
		filename200="./result/teste$testeFolder/result_t200_b$n"
		filename300="./result/teste$testeFolder/result_t300_b$n"

		output100="./result/teste$testeFolder/output_t100_b$n"
		output200="./result/teste$testeFolder/output_t200_b$n"
		output300="./result/teste$testeFolder/output_t300_b$n"
		
		cp ./Teste/testes/$n/*.vhd ./vhdl/ &&
		./bin/run.sh -v pipe.sav -u u -t 100 -n 1>"$output100" 2>"$filename100" &&
		./bin/run.sh -v pipe.sav -u u -t 200 -n 1>"$output200" 2>"$filename200" &&
		./bin/run.sh -v pipe.sav -u u -t 300 -n 1>"$output300" 2>"$filename300" &&	
		n=$(( n*2 ))	 # increments $n
	done

	testeFolder=$(( testeFolder+1 ))
done

#cp ./Teste/testes/2/*.vhd ./vhdl/ &&
#./bin/run.sh -v pipe.sav -u u -t 100 -n 1>output 2>./result/resultb2t100 &&
#./bin/run.sh -v pipe.sav -u u -t 200 -n 1>output 2>./result/resultb2t200 &&
#./bin/run.sh -v pipe.sav -u u -t 300 -n 1>output 2>./result/resultb2t300 &&

#cp ./Teste/testes/4/*.vhd ./vhdl/ &&

#./bin/run.sh -v pipe.sav -u u -t 100 -n 1>output 2>./result/resultb4t100 &&
#./bin/run.sh -v pipe.sav -u u -t 200 -n 1>output 2>./result/resultb4t200 &&
#./bin/run.sh -v pipe.sav -u u -t 300 -n 1>output 2>./result/resultb4t300 &&

#cp ./Teste/testes/8/*.vhd ./vhdl/ &&

#./bin/run.sh -v pipe.sav -u u -t 100 -n 1>output 2>./result/resultb8t100 &&
#./bin/run.sh -v pipe.sav -u u -t 200 -n 1>output 2>./result/resultb8t200 &&
#./bin/run.sh -v pipe.sav -u u -t 300 -n 1>output 2>./result/resultb8t300 &&

#cp ./Teste/testes/16/*.vhd ./vhdl/ &&

#./bin/run.sh -v pipe.sav -u u -t 100 -n 1>output 2>./result/resultb16t100 &&
#./bin/run.sh -v pipe.sav -u u -t 200 -n 1>output 2>./result/resultb16t200 &&
#./bin/run.sh -v pipe.sav -u u -t 300 -n 1>output 2>./result/resultb16t300 &&

#cp ./Teste/testes/32/*.vhd ./vhdl/ &&

#./bin/run.sh -v pipe.sav -u u -t 100 -n 1>output 2>./result/resultb32t100 &&
#./bin/run.sh -v pipe.sav -u u -t 200 -n 1>output 2>./result/resultb32t200 &&
#./bin/run.sh -v pipe.sav -u u -t 300 -n 1>output 2>./result/resultb32t300 &&

#cp ./Teste/testes/64/*.vhd ./vhdl/ &&

#./bin/run.sh -v pipe.sav -u u -t 100 -n 1>output 2>./result/resultb64t100 &&
#./bin/run.sh -v pipe.sav -u u -t 200 -n 1>output 2>./result/resultb64t200 &&
#./bin/run.sh -v pipe.sav -u u -t 300 -n 1>output 2>./result/resultb64t300 &&

#cp ./Teste/testes/128/*.vhd ./vhdl/ &&

#./bin/run.sh -v pipe.sav -u u -t 100 -n 1>output 2>./result/resultb128t100 &&
#./bin/run.sh -v pipe.sav -u u -t 200 -n 1>output 2>./result/resultb128t200 &&
#./bin/run.sh -v pipe.sav -u u -t 300 -n 1>output 2>./result/resultb128t300 &&

##cp ./Teste/testes/256/*.vhd ./vhdl/ &&

#./bin/run.sh -v pipe.sav -u u -t 100 -n 1>output 2>./result/resultb256t100 &&
#./bin/run.sh -v pipe.sav -u u -t 200 -n 1>output 2>./result/resultb256t200 &&
#./bin/run.sh -v pipe.sav -u u -t 300 -n 1>output 2>./result/resultb256t300