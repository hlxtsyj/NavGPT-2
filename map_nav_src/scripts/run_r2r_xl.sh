source /usr/local/anaconda3/bin/activate navgpt
source "$(dirname $(readlink -f "$0"))/.env_vars" 
echo $PYTHONPATH


GPUS=$1

DATA_ROOT=../datasets

train_alg=dagger

features=eva-clip-g
ft_dim=1408

ngpus=1
seed=0
batch_size=2

name=NavGPT2-XL
name=${name}-seed.${seed}
name=${name}-bs${batch_size}

outdir=${DATA_ROOT}/R2R/exprs_map/finetune/${name}

flag="--root_dir ${DATA_ROOT}
      --dataset r2r
      --output_dir ${outdir}
      --world_size ${ngpus}
      --seed ${seed}
      --tokenizer bert      

      --enc_full_graph
      --graph_sprels
      --fusion global

      --expert_policy spl
      --train_alg ${train_alg}
      
      --num_x_layers 4
      
      --max_action_steps 15
      --max_instr_len 200

      --batch_size ${batch_size}
      --lr 1e-5
      --iters 200000
      --log_every 2500
      --optim adamW

      --features ${features}
      --image_feat_size ${ft_dim}
      --angle_feat_size 4

      --ml_weight 0.2   

      --feat_dropout 0.4
      --dropout 0.5
      
      --gamma 0."

# train
# CUDA_VISIBLE_DEVICES=$GPUS python r2r/main_nav.py $flag  \
#         --freeze_qformer \
#         --aug ../datasets/R2R/annotations/prevalent_aug.json \
#         --qformer_ckpt_path models/lavis/output/NavGPT-InstructBLIP-FlanT5XL.pth   # replace with the path to the pretrained qformer

# test
CUDA_VISIBLE_DEVICES=$GPUS python r2r/main_nav.py $flag  \
        --test --submit \
        --freeze_qformer \
        --qformer_ckpt_path models/lavis/output/NavGPT-InstructBLIP-FlanT5XL.pth \
        --resume_file ${outdir}/ckpts/best_val_unseen                              # replace with the path to the best model
