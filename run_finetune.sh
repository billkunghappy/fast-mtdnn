export TASK_NAME=$1
export MODEL_NAME=$2
export POSTFIX=$3
export BATCHSIZE=$4
export CUDA=$5
export SUBDATASET_FINETUNE_FILE=$6
export SUBDATASET_NUM=$7
export USE_PER=100
USE_PER_DIV=$((100/$USE_PER))

source ./python_alias.sh

#need to deal with batch size and steps...
declare -A DATA
if [ "SUBDATASET_NUM" = "-1" ]
then
        DATA=( ['mnli']=$((392702/$USE_PER_DIV))
            ['rte']=$((2490/$USE_PER_DIV))
            ['qqp']=$((363849/$USE_PER_DIV)) 
            ['qnli']=$((104743/$USE_PER_DIV)) 
            ['mrpc']=$((3668/$USE_PER_DIV)) 
            ['sst2']=$((67349/$USE_PER_DIV)) 
            ['cola']=$((8551/$USE_PER_DIV)) 
            ['stsb']=$((5749/$USE_PER_DIV)) 
            ['all']=0 )
else
        DATA=( ['mnli']=$(($SUBDATASET_NUM/$USE_PER_DIV))
            ['rte']=$(($SUBDATASET_NUM/$USE_PER_DIV))
            ['qqp']=$(($SUBDATASET_NUM/$USE_PER_DIV)) 
            ['qnli']=$(($SUBDATASET_NUM/$USE_PER_DIV)) 
            ['mrpc']=$(($SUBDATASET_NUM/$USE_PER_DIV)) 
            ['sst2']=$(($SUBDATASET_NUM/$USE_PER_DIV)) 
            ['cola']=$(($SUBDATASET_NUM/$USE_PER_DIV)) 
            ['stsb']=$(($SUBDATASET_NUM/$USE_PER_DIV)) 
            ['all']=0 )
fi


#Data num
#For not all
D_NUM=${DATA[$TASK_NAME]}
ceildiv(){ echo $((($1+$2-1)/$2)); }
SAVE_STEPS=$( ceildiv $D_NUM $BATCHSIZE )
#For all
if [ "$TASK_NAME" = "all" ]
then
    SAVE_STEPS=0
    for i in "${!DATA[@]}"
    do
        d=${DATA[$i]}
        s=$( ceildiv $d $BATCHSIZE )
        SAVE_STEPS=$(( $SAVE_STEPS + $s ))
    done
fi
echo $SAVE_STEPS

#Run
CUDA_VISIBLE_DEVICES=$CUDA python3 run_glue.py \
  --model_name_or_path results/${MODEL_NAME}_$POSTFIX/ \
  --task_name $TASK_NAME \
  --do_train \
  --do_eval \
  --fp16 \
  --max_seq_length 128 \
  --per_device_train_batch_size $BATCHSIZE \
  --per_device_eval_batch_size 128 \
  --save_steps $SAVE_STEPS \
  --learning_rate 2e-5 \
  --subdataset_file $SUBDATASET_FINETUNE_FILE \
  --num_train_epochs 10 \
  --overwrite_output_dir \
  --output_dir ./results/finetune_${MODEL_NAME}_${POSTFIX}/
  #--model_name_or_path bert-base-cased \

#Need to do this incase that the trainer load the state in finetuning for continue training
#When continue training, modify the trainer_log.json back to trainer_state.json, and the model can continue training
mv ./results/${TASK_NAME}_${POSTFIX}/trainer_state.json ./results/${TASK_NAME}_${POSTFIX}/trainer_log.json
