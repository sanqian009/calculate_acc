#!/bin/bash
# 获取样本文件名
sample_file=$1

# 读取样本文件并生成命令
while IFS= read -r sample
do
    #构建路径
    GVCF1='/work/home/ztron/muhongmei/MH_genomics/step2_gvcf/gtx/gvcf/'${sample}'.g.vcf.gz'
    GVCF2='/work/home/ztron/muhongmei/MH_genomics/step2_gvcf/gvcf/'${sample}'.g.vcf.gz'
    temp='/work/home/ztron/muhongmei/MH_genomics/step2_gvcf/test/temp'


    # Create SLURM job script
    cat << EOF > "./script/${sample}.sh"
#!/bin/bash
#SBATCH -J ${sample}
#SBATCH -p LiuLiHe
##SBATCH --nodelist=b[01]
##SBATCH --array=1
#SBATCH --cpus-per-task=48
#SBATCH -o /work/home/ztron/muhongmei/MH_genomics/step2_gvcf/test/logs/${sample}.o
#SBATCH -e /work/home/ztron/muhongmei/MH_genomics/step2_gvcf/test/logs/${sample}.e


#提取gvcf的位点
zcat ${GVCF1} | awk '!/^#/ awk '!/^#/ {print \$1"_"\$2"_"\$4"_"\$5}' > ${temp}/temp_gtx_${sample}.txt
zcat ${GVCF2} | awk '!/^#/ awk '!/^#/ {print \$1"_"\$2"_"\$4"_"\$5}' > ${temp}/temp_saile_${sample}.txt

#提取alt的位点
grep -Pv '^\d+_\d+_[ATCG]+_<NON_REF>$' ${temp}/temp_gtx_${sample}.txt > ${temp}/gtx_${sample}.txt
grep -Pv '^\d+_\d+_[ATCG]+_<NON_REF>$' ${temp}/temp_saile_${sample}.txt > ${temp}/saile_${sample}.txt

#python计算
python /work/home/ztron/muhongmei/MH_genomics/step2_gvcf/test/compare_gtx_saile.py ${temp}/gtx_${sample}.txt ${temp}/saile_${sample}.txt
python /work/home/ztron/muhongmei/MH_genomics/step2_gvcf/test/compare_merge.py ${temp}/gtx_${sample}.txt ${temp}/saile_${sample}.txt

rm /work/home/ztron/muhongmei/MH_genomics/step2_gvcf/test/temp/temp_*

EOF

done < "$sample_file"
