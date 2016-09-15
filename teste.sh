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
	if [ $testeFolder -ge 5 ] && [ $testeFolder -lt 7 ]
	then
		filename10000="./result/teste$testeFolder/result_t10000_b$n"
		output10000="./result/teste$testeFolder/output/output_t10000_b$n"
		./bin/run.sh -v pipe.sav -u u -t 10000 -n 1>"$output10000" 2>"$filename10000"
	else
		while [ $n -le $4 ] || [ $n == 7 ]
		do
			echo "BCD $n"
			filename100="./result/teste$testeFolder/result_t100_b$n" 
			filename200="./result/teste$testeFolder/result_t200_b$n"
			filename300="./result/teste$testeFolder/result_t300_b$n"
			filename500="./result/teste$testeFolder/result_t500_b$n"
			filename2000="./result/teste$testeFolder/result_t2000_b$n"

			output100="./result/teste$testeFolder/output/output_t100_b$n"
			output200="./result/teste$testeFolder/output/output_t200_b$n"
			output300="./result/teste$testeFolder/output/output_t300_b$n"
			output500="./result/teste$testeFolder/output/output_t500_b$n"
			output2000="./result/teste$testeFolder/output/output_t2000_b$n"
			

			cp ./Teste/testes/$n/*.vhd ./vhdl/ &&
			#./bin/run.sh -v pipe.sav -u u -t 100 -n 1>"$output100" 2>"$filename100" &&
			#./bin/run.sh -v pipe.sav -u u -t 200 -n 1>"$output200" 2>"$filename200" &&
			#./bin/run.sh -v pipe.sav -u u -t 300 -n 1>"$output300" 2>"$filename300" &&	
			#./bin/run.sh -v pipe.sav -u u -t 500 -n 1>"$output500" 2>"$filename500" &&	
			./bin/run.sh -v pipe.sav -u u -t 2000 -n 1>"$output2000" 2>"$filename2000" &&	
			n=$(( n*2 ))	 # increments $n
		done
	fi

	testeFolder=$(( testeFolder+1 ))
done
