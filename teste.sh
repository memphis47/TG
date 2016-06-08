testeFolder=$1
while [ $testeFolder -le $2 ]
do
	echo "Teste $testeFolder"
	cp ./Teste/Teste$testeFolder/*.c ./cLupaInput/ &&
	cd cLupaInput &&
	#cp ./back/*.bin ./ &&
	#cp ./back/*.bin ../ &&
	rm -rf prog1.bin prog.bin data.bin data1.bin 2>&1 && 
	rm -rf ../prog1.bin ../prog.bin ../data.bin ../data1.bin 2>&1 && 
	../bin/compile.sh core1.c && 
	cp data.bin data1.bin && cp prog.bin prog1.bin && 
	../bin/compile.sh core0.c && 
	cp *.bin ../ &&
	cd .. &&

	n=$3

	# continue until $n equals 256
	mkdir -p "./result/teste$testeFolder/" &&
	mkdir -p "./result/teste$testeFolder/output" &&
	while [ $n -le $4 ]
	do
		echo "BCD $n"
		filename100="./result/teste$testeFolder/result_t100_b$n" 
		filename200="./result/teste$testeFolder/result_t200_b$n"
		filename300="./result/teste$testeFolder/result_t300_b$n"

		output100="./result/teste$testeFolder/output/output_t100_b$n"
		output200="./result/teste$testeFolder/output/output_t200_b$n"
		output300="./result/teste$testeFolder/output/output_t300_b$n"
		
		cp ./Teste/testes/$n/*.vhd ./vhdl/ &&
		./bin/run.sh -v pipe.sav -u u -t 100 -n 1>"$output100" 2>"$filename100" &&
		./bin/run.sh -v pipe.sav -u u -t 200 -n 1>"$output200" 2>"$filename200" &&
		./bin/run.sh -v pipe.sav -u u -t 300 -n 1>"$output300" 2>"$filename300" &&	
		n=$(( n*2 ))	 # increments $n
	done

	testeFolder=$(( testeFolder+1 ))
done