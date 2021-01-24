export TASK_NAME=rte
export POSTFIX=test

CUDA_VISIBLE_DEVICES=1 python3 run_glue.py \
  --model_name_or_path ./results/${TASK_NAME}_${POSTFIX}/ \
  --task_name $TASK_NAME \
  --do_eval \
  --max_seq_length 128 \
  --per_device_eval_batch_size 128 \
  --output_dir ./results/${TASK_NAME}_${POSTFIX}/
