# -------------------------------
# Install Packages
# -------------------------------
install.packages(c(
  "ggplot2","cluster","dplyr","corrplot","scales" ,"smotefamily",
  "caret","pROC","rpart", "rpart.plot", "randomForest", "e1071",
  "tidyr","fastDummies", "mice", "class"))


# -------------------------------
# Load Packages
# -------------------------------

library(tidyr)
library(scales)
library(corrplot)
library(cluster)
library(dplyr)
library(ggplot2)
library(caret)
library(smotefamily)
library(pROC)
library(rpart)
library(rpart.plot)
library(randomForest)
library(e1071)
library(fastDummies)
library(mice)
library(class)

########################
# CSDA 6010 – Project 1
# Voter Persuasion Analysis
###########################

#2 Read data
VoterPersuasion <- read.csv("VoterPersuasion.csv", stringsAsFactors = FALSE)
head(VoterPersuasion)

#data understanding
# check structure and data types
str(VoterPersuasion)

# view dataset size (rows, columns)
dim(VoterPersuasion)

# list all variable names
names(VoterPersuasion)

# summary statistics for each variable
summary(VoterPersuasion)

# count variables by data type
table(sapply(VoterPersuasion, class))

# check missing values by column
missing_vals <- sort(colSums(is.na(VoterPersuasion)), decreasing = TRUE)

# display columns with missing values only
missing_vals[missing_vals >0]

# identify numeric columns 
numeric_idx <- sapply(VoterPersuasion, is.numeric)
# subset dataset to numeric variables only
numeric_cols <- VoterPersuasion[, numeric_idx]

# remove identifier columns and target variable
numeric_cols <- numeric_cols %>%
  select(-c('X','VOTER_ID','MOVED_A'))

# keep numeric columns with more than 4 unique values
num_col_more_than_4_df <- numeric_cols[
  , sapply(numeric_cols, function(x) length(unique(na.omit(x))) > 4)]
# view filtered numeric columns
num_col_more_than_4_df

# inspect unique values for each numeric column
lapply(num_col_more_than_4_df, unique)

# count number of remaining numeric columns
length(num_col_more_than_4_df)

# count zero values in each numeric column
colSums(num_col_more_than_4_df ==0, na.rm = TRUE)

# select specific numeric columns for closer inspection
cols_to_check <- c(
  "OPP_SEX", "UPSCALEBUY", "UPSCALEFEM", "FEMALEORIE",
  "GARDENINGM", "DOITYOURSE", "FINANCIALM",
  "PR_PELIG", "AP_PELIG"
)
# inspect unique values for selected numeric columns
lapply(num_col_more_than_4_df[, cols_to_check], unique)

# Data Exploration

# visualize target distribution to assess class imbalance
barplot(table(VoterPersuasion$MOVED_A),
        main = "Distribution of Voter Movement (MOVED_A)",
        xlab = "Moved after message",
        ylab = "Count",
        col = c("lightblue","salmon")
        )
"Most voters did not change their position after receiving a message, indicating class 
imbalance and the need for targeted persuasion rather than mass outreach."

# compare age distribution by voter movement status
boxplot(AGE ~ MOVED_A, data = VoterPersuasion, 
        main="Age by Voter Movement", 
        xlab = "Moved After Message", 
        ylab = "AGE", 
        col = c("lightblue","salmon"))
"Age distributions are similar for voters who moved and did not move, indicating that 
age alone is not a strong predictor of voter movement."

# compare household income by voter movement status
boxplot(data= VoterPersuasion, MED_HH_INC~ MOVED_A,
        main = "Income by Voter Movement",
        xlab = "Moved After Message",
        ylab = "Median Household Income",
        col = c("lightblue","salmon")
        )
"Median household income distributions are very similar for voters who moved and did 
not move, suggesting income alone is not a strong predictor of voter movement."

# summarize party registration counts
party_df <- data.frame(
  party =c("Democrat","Independent","Republican"),
  count = c(
    sum(VoterPersuasion$PARTY_D),
    sum(VoterPersuasion$PARTY_I),
    sum(VoterPersuasion$PARTY_R)
  )
)

# visualize party registration distribution
barplot(party_df$count,
        names.arg = party_df$party,
        col = c("lightblue","salmon","lightgreen"),
        main = "Party Registration Distribution"
        )
"The dataset contains more Democrats than Republicans or Independents, indicating an
imbalanced party registration distribution."

# examine persuasion outcomes for Democrats
table(VoterPersuasion$PARTY_D, VoterPersuasion$MOVED_A)
# examine persuasion outcomes for Independents
table(VoterPersuasion$PARTY_I, VoterPersuasion$MOVED_A)
# examine persuasion outcomes for Republicans
table(VoterPersuasion$PARTY_R, VoterPersuasion$MOVED_A)

# create contingency table for 2012 voting history and persuasion
tab <- table(VoterPersuasion$VG_12, VoterPersuasion$MOVED_A)
# visualize persuasion rates by 2012 voting status
barplot(prop.table(tab, margin = 1),
        beside = TRUE,
        col = c("lightblue","salmon"),
        legend = TRUE,
        args.legend = list(title="MOVED_A"),
        main = "Voting in 2012 vs Persuasion",
        xlab = "Voted in 2012"
        )
"Voters who did vote in 2012 show a higher likelihood of being persuaded (MOVED_A = 1) 
compared to those who did not vote in 2012"

# compute average upscale buying score by persuasion outcome
means <- tapply(VoterPersuasion$UPSCALEBUY, VoterPersuasion$MOVED_A, mean)
# compare average upscale buying score across movement groups
barplot(means, col = c("lightblue","salmon"),
        names.arg = c("Not Moved", "Moved"),
        main ="Average Upscale buing score by persuasion",
        ylab = "Mean Upscale Buy Index",
        xlab = "Moved after Message"
        )
"Although voters who moved have a slightly higher average Upscale Buying score, the values are close 
to zero for both groups, indicating minimal practical value for identifying persuadable voters."

# examine effect of Message A on voter movement
barplot(table(VoterPersuasion$MESSAGE_A, VoterPersuasion$MOVED_A),
        beside = TRUE,
        col = c("lightblue","salmon"),
        legend = TRUE,
        args.legend = list(title= "MOVED_A"),
        main = "Effect of Message A on Voter Movement",
        xlab = "Received Message A"
        )
"The chart shows that voters who received Message A were more likely to move than those who 
did not, indicating that Message A had a positive effect on persuasion."

## visualize baseline persuasion rate
barplot(prop.table(table(VoterPersuasion$MOVED_A)),
        main = "Baseline Persuasion Rate",
        ylab = "Proportion",
        col = c("lightblue","salmon"))

"The outcome variable is moderately imbalanced, with a higher proportion of voters not moving after 
exposure. This baseline rate was used as a reference when evaluating the added value of predictors."

# assess usefulness of gender (female) in predicting persuasion
barplot(prop.table(table(VoterPersuasion$GENDER_F, VoterPersuasion$MOVED_A),1),
        beside = TRUE,
        col = c("lightblue","salmon"),
        legend = TRUE,
        args.legend = list(title = "MOVED_A"),
        main = "Gender(Female) vs Persuasion",
        xlab = "Female = 1"
)
"Female voters show a higher persuasion rate than male voters, indicating gender provides 
useful signal for predicting movement. we'll drop one gender to avoid redundancy"

# create binary indicator for having children
VoterPersuasion$HAS_KIDS <- ifelse(VoterPersuasion$KIDS > 0, 1, 0)
# compare persuasion rates for parents vs non-parents
barplot(prop.table(table(VoterPersuasion$HAS_KIDS, VoterPersuasion$MOVED_A),1),
        beside = TRUE,
        col = c("lightblue","salmon"),
        legend= TRUE,
        args.legend = list(title= "MOVED_A"),
        main = "Parents vs Persuasion",
        xlab = "Has Kids"
        )
"Voters without kids are more likely to be persuaded than voters with kids, so having kids 
does not increase persuasion and may slightly reduce it. so we can remove kids"

# assess effect of married male presence in household on persuasion
barplot(prop.table(table(VoterPersuasion$M_MAR, VoterPersuasion$MOVED_A), 1),
        beside = TRUE,
        col = c("lightblue","salmon"),
        main = "Married Male in Household vs Persuasion")

# compare neighborhood percentage of married men and women by persuasion outcome
boxplot(
  cbind(F_MAR, M_MAR) ~ MOVED_A,
  data = VoterPersuasion,
  col = c("lightblue","salmon"),
  main = "Neighborhood % Married by Persuasion",
  ylab = "Percent"
)
" The chart shows that voters from areas with different percentages of married men or women behave 
similarly, with no clear difference in persuasion between those who moved and those who did not."

# compare number of Democrats in household by persuasion outcome
boxplot(HH_ND ~ MOVED_A, data = VoterPersuasion,
        col= c("lightblue", "salmon"),
        main = "Household Democrats vs Persuasion",
        ylab = "Number of Democrats in Household"
        )

# compare number of Republicans in household by persuasion outcome
boxplot(HH_NR ~ MOVED_A, data = VoterPersuasion,
        col= c("lightblue", "salmon"),
        main = "Household Republicans vs Persuasion",
        ylab = "Number of registered Republicans in household"
)

# compare number of Independents in household by persuasion outcome
boxplot(HH_NI ~ MOVED_A, data = VoterPersuasion,
        col= c("lightblue", "salmon"),
        main = "Household Independents vs Persuasion",
        ylab = "Number of registered Independents in household"
)
"households with more Democrats show slightly higher persuasion; Republicans show lower; Independents show no clear pattern"

# compare neighborhood racial composition by persuasion outcome
boxplot(NH_WHITE ~ MOVED_A, data = VoterPersuasion,
        col = c("lightblue","salmon"),
        main ="Neighborhood % White vs Persuasion",
        ylab = "Percent"
        )
boxplot(NH_AA ~ MOVED_A, data = VoterPersuasion,
        col = c("lightblue","salmon"),
        main ="Neighborhood % African American  vs Persuasion",
        ylab = "Percent"
)
boxplot(NH_ASIAN ~ MOVED_A, data = VoterPersuasion,
        col = c("lightblue","salmon"),
        main ="Neighborhood % Asian vs Persuasion",
        ylab = "Percent"
)
boxplot(NH_MULT ~ MOVED_A, data = VoterPersuasion,
        col = c("lightblue","salmon"),
        main ="Neighborhood % multiracial  vs Persuasion",
        ylab = "Percent"
)
boxplot(HISP ~ MOVED_A, data = VoterPersuasion,
        col = c("lightblue","salmon"),
        main ="Neighborhood % Hispanic  vs Persuasion",
        ylab = "Percent"
)
"Neighborhood race percentages look very similar for persuaded and non-persuaded voters,
showing no clear difference and limited predictive value."

# Community & Transportation
boxplot(COMM_CAR ~ MOVED_A, data = VoterPersuasion,
        col = c("lightblue","salmon"),
        main = "Commute by Car vs Persuasion",
        ylab = "%")
boxplot(COMM_LT10 ~ MOVED_A, data = VoterPersuasion,
        col = c("lightblue","salmon"),
        main = "commuting less than 10 minutes vs Persuasion",
        ylab = "%")
boxplot(COMM_609P ~ MOVED_A, data = VoterPersuasion,
        col = c("lightblue","salmon"),
        main = "commuting 60-90+ minutes vs Persuasion",
        ylab = "%")
boxplot(COMM_CP ~ MOVED_A, data = VoterPersuasion,
        col = c("lightblue","salmon"),
        main = "Commute via carpool vs Persuasion",
        ylab = "%")
boxplot(COMM_PT ~ MOVED_A, data = VoterPersuasion,
        col = c("lightblue","salmon"),
        main = "commuting via Public Transit vs Persuasion",
        ylab = "%")
boxplot(COMM_WALK ~ MOVED_A, data = VoterPersuasion,
        col = c("lightblue","salmon"),
        main = "commuting by Walking vs Persuasion",
        ylab = "%")
"People’s commuting habits look almost the same
for voters who were persuaded and those who were not, so commuting does not really affect persuasion."


# assess community transportation patterns by persuasion outcome
boxplot(G_PELIG ~ MOVED_A, data = VoterPersuasion, col = c("lightblue","salmon"),
        main = "Probability of voting in general election vs Persuasion")

boxplot(PP_PELIG ~ MOVED_A, data = VoterPersuasion, col = c("lightblue","salmon"),
        main = "Probability of voting in primary election vs Persuasion")

boxplot(PR_PELIG ~ MOVED_A, data = VoterPersuasion, col = c("lightblue","salmon"),
        main = "Probability of voting in Republican primary vs Persuasion")

boxplot(AP_PELIG ~ MOVED_A, data = VoterPersuasion, col = c("lightblue","salmon"),
        main = "Probability of voting in any primary vs Persuasion")

boxplot(E_PELIG ~ MOVED_A, data = VoterPersuasion, col = c("lightblue","salmon"),
        main = "Overall electoral participation likelihood vs Persuasion")

"Overall electoral engagement and primary participation show clearer differences between 
persuaded and non-persuaded voters, so E_PELIG, PP_PELIG, and PR_PELIG were retained, 
while G_PELIG and AP_PELIG were removed due to limited additional value."

# compare neighborhood general-election partisan score by persuasion outcome
boxplot(NL5G ~ MOVED_A, data = VoterPersuasion,
        col = c("lightblue","salmon"),
        main = "5-point neighborhood general-election partisan score vs Persuasion")
"Both groups (MOVED = 0 and 1) look almost the same → no clear difference."

# compare neighborhood Republican lean by persuasion outcome
boxplot(NL3PR  ~ MOVED_A, data = VoterPersuasion,
        col = c("lightblue","salmon"),
        main = "3-point neighborhood Republican score vs Persuasion")
"People who were persuaded tend to live in slightly more Republican-leaning neighborhoods → some signal."

# compare all-party neighborhood score by persuasion outcome
boxplot(NL5AP  ~ MOVED_A, data = VoterPersuasion,
        col = c("lightblue","salmon"),
        main = "5-point all-party neighborhood score vs Persuasion")
"Very similar for both groups → little information."

# compare neighborhood primary participation score by persuasion outcome
boxplot(NL2PP  ~ MOVED_A, data = VoterPersuasion,
        col = c("lightblue","salmon"),
        main = "2-point primary participation score vs Persuasion")
"Persuaded voters are more likely to have some primary participation → clearer pattern."

# check relationship between post-ad movement and final movement
barplot(prop.table(table(VoterPersuasion$MOVED_AD, VoterPersuasion$MOVED_A), 1),
        beside = TRUE,
        col = c("lightblue","salmon"),
        main = "Post-Ad Movement vs Final Movement")
"Post-ad movement duplicates final movement, so it was removed to avoid redundancy."

# define target variable
target <- VoterPersuasion$MOVED_A

# compute correlation between numeric predictors and target
cor_values <-sapply(numeric_cols, function(x){
  cor(x,target, use = "complete.obs")
})
# rank predictors by absolute correlation strength
sort(abs(cor_values), decreasing = TRUE)

# variables were assessed using charts and correlation measures to identify useful and redundant predictors
remove_vars <- c(
  "X", "VOTER_ID", "SET_NO",
  "GENDER_M", "PARTY_I", "MESSAGE_A_REV", "MOVED_AD",
  "KIDS", "M_MAR", "F_MAR", "HH_NI",
  "NH_WHITE", "NH_AA", "NH_ASIAN", "NH_MULT", "HISP",
  "COMM_CAR", "COMM_LT10", "COMM_609P", "COMM_CP", "COMM_WALK",
  "BOOKBUYERI", "FINANCIALM", "HEALTHFITN", "GARDENINGM",
  "CULINARYIN", "DOITYOURSE", "FAMILYMAGA",
  "RELIGIOUSM", "RELIGIOUSC",
  "UPSCALEBUY", "UPSCALEMAL", "UPSCALEFEM", "FEMALEORIE","HAS_KIDS","opposite"
)

# remove selected low-value and redundant variables
VoterPersuasion_clean <- VoterPersuasion %>%
  select(-any_of(remove_vars))

# quick checks on cleaned dataset
# confirm dataset size
dim(VoterPersuasion_clean)
# review remaining variables
names(VoterPersuasion_clean)
# preview first few rows
head(VoterPersuasion_clean)

# inspect unique values for selected categorical variables
unique(VoterPersuasion_clean$CAND1S)
unique(VoterPersuasion_clean$CAND2S)
unique(VoterPersuasion_clean$I3)
unique(VoterPersuasion_clean$CAND1_UND)
unique(VoterPersuasion_clean$CAND2_UND)

names(VoterPersuasion_clean)

# # convert selected categorical variables to binary indicators
VoterPersuasion_clean <- VoterPersuasion_clean %>%
  mutate(
    I3 = ifelse(I3 =="Y",1,0),
    CAND1_UND = ifelse(CAND1_UND =="Y",1,0),
    CAND2_UND = ifelse(CAND2_UND =="Y",1,0)
  )
# verify updated variable names
names(VoterPersuasion_clean)

# create dummy variables for candidate support categories and remove originals
VoterPersuasion_clean <- dummy_cols(
  VoterPersuasion_clean,
  select_columns = c("CAND1S", "CAND2S"),
  remove_first_dummy = TRUE,
  remove_selected_columns = TRUE
)
# verify updated variable names
names(VoterPersuasion_clean)

# separate outcome variable and predictors
voter_moved <- VoterPersuasion_clean$MOVED_A

voter_predictors <- VoterPersuasion_clean %>%
  select(-MOVED_A)

# set seed for reproducibility and create stratified 70–30 train-test split
set.seed(2000)

train_idx <- createDataPartition(
  voter_moved,
  p = 0.7,
  list = FALSE
)

# split predictors and outcome into training set
train_pred <- voter_predictors[train_idx, ]
train_outcome <- voter_moved[train_idx]

# split predictors and outcome into test set
test_pred <- voter_predictors[-train_idx, ]
test_outcome <- voter_moved[-train_idx]

# check class distribution overall and in train/test splits
prop.table(table(voter_moved))
prop.table(table(train_outcome))
prop.table(table(test_outcome))

# remove MESSAGE_A before PCA and apply PCA on training predictors only
train_pred_pca <- train_pred %>%
  select(-MESSAGE_A)
test_pred_pca <- test_pred %>%
  select(-MESSAGE_A)

pca_train <- prcomp(train_pred_pca, scale. = TRUE)
# review variance explained by principal components
summary(pca_train)

# project training and test data onto PCA space
train_pcs <- predict(pca_train, train_pred_pca)
test_pcs <- predict(pca_train, test_pred_pca)

# determine number of PCs explaining at least 85% of total variance
var_exp <- cumsum(pca_train$sdev^2 / sum(pca_train$sdev^2))
k <- which(var_exp >=0.85)[1]

# retain only the first k principal components
train_pcs <- train_pcs[, 1:k]
test_pcs <- test_pcs[, 1:k]

# combine outcome, selected PCs, and MESSAGE_A into final training dataset
train_final <- data.frame(
  MOVED_A = train_outcome,
  train_pcs,
  MESSAGE_A = train_pred$MESSAGE_A
)

# combine outcome, selected PCs, and MESSAGE_A into final test dataset
test_final <- data.frame(
  MOVED_A = test_outcome,
  test_pcs,
  MESSAGE_A = test_pred$MESSAGE_A
)

# Model Selection

# logistic regression
# fit logistic regression model on training data
logit_model <- glm(MOVED_A ~., data = train_final, family = binomial)
summary(logit_model)

# generate predicted probabilities on test set
pred_prob <- predict(logit_model, test_final, type = "response")
pred_class <- ifelse(pred_prob > 0.5,1,0)

# evaluate model performance using confusion matrix
confusionMatrix(factor(pred_class, levels = c(0, 1)),
                factor(test_final$MOVED_A, levels = c(0, 1)),
                positive = "1")

# compute and plot ROC curve and AUC for logistic regression 
logit_roc_obj <- roc(test_final$MOVED_A, pred_prob)
auc(logit_roc_obj)
plot(logit_roc_obj)

# fit logistic regression without MESSAGE_A to assess its incremental value
logit_no_msg <- glm(
  MOVED_A ~ .,
  data = train_final %>% select(-MESSAGE_A),
  family = binomial
)

# evaluate model performance without MESSAGE_A
pred_no_msg <- predict(logit_no_msg, test_final, type = "response")
roc_no_msg <- roc(test_final$MOVED_A, pred_no_msg)
auc(roc_no_msg)

"Excluding Message A slightly reduces model performance (AUC decreases
from 0.850 to 0.849), indicating that Message A provides modest but meaningful
incremental predictive value beyond voter characteristics."

#Decision Tree

# train classification tree on training data
set.seed(2000)
tree_model <- rpart(
  MOVED_A ~.,
  data = train_final,
  method = "class",
  control = rpart.control(cp =0.01, minsplit = 30)
)

# visualize decision tree and inspect complexity parameter
rpart.plot(tree_model, type = 2, extra = 104, fallen.leaves = TRUE)
# view cross-validated error by cp
printcp(tree_model)
# plot cp vs cross-validated error
plotcp(tree_model)

# prune tree using cp with minimum cross-validated error
best_cp <- tree_model$cptable[which.min(tree_model$cptable[,"xerror"]), "CP"]
tree_pruned <- prune(tree_model, cp = best_cp)

# visualize pruned decision tree and confirm final complexity
rpart.plot(tree_pruned, type = 2, extra = 104, fallen.leaves = TRUE)
printcp(tree_pruned)

# generate class predictions on test set using pruned tree
tree_pred_class <- predict(tree_pruned, test_final, type = "class")

# evaluate decision tree performance using confusion matrix
confusionMatrix(factor(tree_pred_class, levels = c(0,1)),
                factor(test_final$MOVED_A, levels = c(0,1)),
                positive = "1")

# obtain predicted probabilities for positive class from pruned tree
tree_pred_prob <- predict(tree_pruned, test_final, type = "prob")[,"1"]

# compute and plot ROC curve and AUC for the decision tree model
tree_roc_obj <- roc(test_final$MOVED_A, tree_pred_prob)
auc(tree_roc_obj)
plot(tree_roc_obj)

#KNN 

# prepare predictor matrices for kNN (PCs + MESSAGE_A)
x_train_knn <- train_final %>% select(-MOVED_A)
x_test_knn <- test_final %>% select(-MOVED_A)

# extract outcome variable for kNN
y_train_knn <- train_final$MOVED_A
y_test_knn <- test_final$MOVED_A

# set seed for reproducibility before kNN cross-validation
set.seed(2000)

# define cross-validation settings and ROC-based evaluation for kNN
ctrl <- trainControl(
  method = "cv",
  number = 10,
  classProbs = TRUE,
  summaryFunction = twoClassSummary
)

# train kNN model using cross-validation and select k based on ROC
knn_cv <- train(
  x= x_train_knn,
  y= factor(y_train_knn, levels = c(0,1), labels = c("No","Yes")),
  method = "knn",
  tuneGrid = data.frame(k=seq(3,11,by=2)),
  trControl = ctrl,
  metric = "ROC"
)

# review cross-validation results and visualize ROC performance across k values
knn_cv
plot(knn_cv)

# extract optimal number of neighbors from cross-validation 
best_k <- knn_cv$bestTune$k
best_k

# generate class predictions on test set using optimal k
knn_pred_class <- knn(
  train = x_train_knn,
  test = x_test_knn,
  cl = y_train_knn,
  k= best_k
)

# evaluate kNN model performance using confusion matrix
confusionMatrix(
  factor(knn_pred_class, levels = c(0,1)),
  factor(y_test_knn, levels = c(0,1)),
  positive = "1"
)

# obtain predicted probabilities for positive class from kNN model
knn_prob <- predict(knn_cv, x_test_knn, type = "prob")[,"Yes"]

# compute and plot ROC curve and AUC for kNN model
knn_roc <- roc(y_test_knn, knn_prob)
auc(knn_roc)
plot(knn_roc)


##############################
# CSDA 6010 – Project 2
# Consumer Behavior Analytics
##############################

# -------------------------------
# Read Data
# -------------------------------

# Read the Home Equity dataset
HomeEquityData <- read.csv("hmeq.csv", stringsAsFactors = FALSE)

# Preview the first few rows of the dataset
head(HomeEquityData)

# Check the structure of the dataset
str(HomeEquityData)

# Check the number of rows and columns
dim(HomeEquityData)

# Display variable names
names(HomeEquityData)

# View summary statistics
summary(HomeEquityData)

# -------------------------------
# Missing Values Check
# -------------------------------

# Count missing values in each column
colSums(is.na(HomeEquityData))

# Calculate percentage of missing values in each column
round(colMeans(is.na(HomeEquityData)) * 100, 2)

# Count missing values in each row
rowSums(is.na(HomeEquityData))

# Summarize how many rows have 0, 1, 2, etc. missing values
table(rowSums(is.na(HomeEquityData)))

# Check unique values in JOB and REASON to identify blank strings
unique(HomeEquityData$JOB)
unique(HomeEquityData$REASON)

# Convert blank strings in REASON and JOB into proper NA values
HomeEquityData$REASON[HomeEquityData$REASON == ""] <- NA
HomeEquityData$JOB[HomeEquityData$JOB == ""] <- NA

# Check again after cleaning blank values
unique(HomeEquityData$JOB)
unique(HomeEquityData$REASON)

# -------------------------------
# Missingness Indicator
# -------------------------------

# Create an indicator variable showing whether DEBTINC is missing
HomeEquityData$DEBTINC_MISS <- ifelse(is.na(HomeEquityData$DEBTINC), 1, 0)

# Compare missingness of DEBTINC with BAD to see if missingness is informative
prop.table(table(HomeEquityData$DEBTINC_MISS, HomeEquityData$BAD), 1)

# -------------------------------
# Zero Handling in Numeric Columns
# -------------------------------

# Identify numeric columns
num_cols <- sapply(HomeEquityData, is.numeric)

# Count how many zero values appear in each numeric variable
sapply(HomeEquityData[, num_cols], function(x) sum(x == 0, na.rm = TRUE))

# -------------------------------
# Missing Pattern Visualization
# -------------------------------

# Adjust plotting size for the missing data pattern plot
par(cex = 0.5)

# Display the pattern of missing values across variables
md.pattern(HomeEquityData, rotate.names = TRUE)

# -------------------------------
# Numeric Summary
# -------------------------------

# Identify numeric variables
comp_num_vars <- sapply(HomeEquityData, is.numeric)

# Show summary statistics for numeric variables only
summary(HomeEquityData[, comp_num_vars])

# Compute average values of numeric variables grouped by BAD
aggregate(HomeEquityData[, setdiff(names(HomeEquityData)[comp_num_vars], "BAD")],
          by = list(BAD = HomeEquityData$BAD),
          FUN = function(x) mean(x, na.rm = TRUE))

# -------------------------------
# Data Exploration
# -------------------------------

# Plot the distribution of the target variable BAD to check class imbalance
barplot(table(HomeEquityData$BAD),
        main = "Distribution of Default (BAD)",
        col = c("lightblue","salmon"),
        names.arg = c("No Default","Default"))

# Scatter plot to explore the relationship between loan amount and property value
plot(HomeEquityData$LOAN, HomeEquityData$VALUE,
     main = "Loan vs Property Value",
     xlab = "Loan",
     ylab = "Value")

# Density plot of DEBTINC grouped by BAD
ggplot(HomeEquityData[!is.na(HomeEquityData$DEBTINC), ],
       aes(x = DEBTINC, fill = as.factor(BAD))) +
  geom_density(alpha = 0.5) +
  labs(title = "Debt-to-Income by Default Status",
       fill = "BAD")

# Histogram to inspect the distribution of DEBTINC
hist(HomeEquityData$DEBTINC,
     main = "Distribution of Debt-to-Income Ratio",
     xlab = "DEBTINC",
     col = "lightblue",
     cex.main = 1.8,
     cex.axis = 1.8,
     cex.lab = 1.5)

# Boxplot to compare DEBTINC between default and non-default borrowers
boxplot(DEBTINC ~ BAD, data = HomeEquityData,
        main = "DEBTINC by Default Status",
        col = c("lightblue", "salmon"),
        cex.main = 1.8,
        cex.axis = 1.8,
        cex.lab = 1.5)

# Boxplot to compare DELINQ between default and non-default borrowers
boxplot(DELINQ ~ BAD, data = HomeEquityData,
        main = "Delinquency by Default",
        col = c("lightblue", "salmon"),
        cex.main = 1.8,
        cex.axis = 1.8,
        cex.lab = 1.5)

# Outlier detection for LOAN
boxplot(HomeEquityData$LOAN,
        main = "Loan Outliers",
        cex.main = 1.8,
        cex.axis = 1.8)

# Outlier detection for VALUE
boxplot(HomeEquityData$VALUE,
        main = "Value Outliers",
        cex.main = 1.8,
        cex.axis = 1.8)

# Outlier detection for DEBTINC
boxplot(HomeEquityData$DEBTINC,
        main = "DEBTINC Outliers",
        cex.main = 1.8,
        cex.axis = 1.8)

# -------------------------------
# Convert Categorical Variables to Factor
# -------------------------------

# Convert JOB to factor for analysis and modeling
HomeEquityData$JOB <- as.factor(HomeEquityData$JOB)

# Convert REASON to factor for analysis and modeling
HomeEquityData$REASON <- as.factor(HomeEquityData$REASON)

# -------------------------------
# Split Data
# -------------------------------

# Set seed for reproducibility
set.seed(2026)

# Split data into 70% training and 30% testing while preserving BAD distribution
train_idx <- createDataPartition(HomeEquityData$BAD, p = 0.70, list = FALSE)

# Create training dataset
train_df <- HomeEquityData[train_idx, ]

# Create testing dataset
test_df  <- HomeEquityData[-train_idx, ]


# -------------------------------
# Impute Missing Values
# -------------------------------
train_for_impute <- train_df[, !(names(train_df) %in% c("BAD", "DEBTINC_MISS"))]
test_for_impute  <- test_df[, !(names(test_df) %in% c("BAD", "DEBTINC_MISS"))]

imp_train <- mice(train_for_impute, m = 5, method = "pmm", seed = 2026, printFlag = FALSE)
train_imputed_part <- complete(imp_train, 1)

imp_test <- mice.mids(imp_train, newdata = test_for_impute, maxit = 5, printFlag = FALSE)
test_imputed_part <- complete(imp_test, 1)

train_imputed <- cbind(
  BAD = train_df$BAD,
  train_imputed_part,
  DEBTINC_MISS = train_df$DEBTINC_MISS
)

test_imputed <- cbind(
  BAD = test_df$BAD,
  test_imputed_part,
  DEBTINC_MISS = test_df$DEBTINC_MISS
)
# -------------------------------
# Correlation Analysis
# -------------------------------

# Identify numeric variables in imputed training data
comp_num_vars <- sapply(train_imputed, is.numeric)

# Compute correlation matrix for numeric variables
cor_matrix <- cor(train_imputed[, comp_num_vars])

# Display rounded correlation matrix
round(cor_matrix, 2)

# Visualize correlation matrix
corrplot(cor_matrix, method = "color", tl.cex = 1.2)

# -------------------------------
# Categorical Predictors vs BAD
# -------------------------------

# Show row proportions of REASON by BAD
prop.table(table(train_imputed$REASON, train_imputed$BAD), 1)

# Show row proportions of JOB by BAD
prop.table(table(train_imputed$JOB, train_imputed$BAD), 1)

# Count BAD values
table(train_imputed$BAD)

# Show proportion of BAD values
prop.table(table(train_imputed$BAD))

# Convert BAD to factor in both train and test datasets
train_imputed$BAD <- as.factor(train_imputed$BAD)
test_imputed$BAD <- as.factor(test_imputed$BAD)

# =========================================================
# CLASSIFICATION SECTION
# =========================================================

# -------------------------------
# Create Dummy Variables
# -------------------------------

# Convert categorical predictors in training data into dummy variables
train_dummy <- dummy_cols(
  train_imputed,
  select_columns = c("REASON", "JOB"),
  remove_first_dummy = TRUE,
  remove_selected_columns = TRUE
)

# Convert categorical predictors in testing data into dummy variables
test_dummy <- dummy_cols(
  test_imputed,
  select_columns = c("REASON", "JOB"),
  remove_first_dummy = TRUE,
  remove_selected_columns = TRUE
)

# Identify columns present in train but missing in test
missing_cols <- setdiff(names(train_dummy), names(test_dummy))

# Add missing columns to test data and fill them with 0
for (col in missing_cols) {
  test_dummy[[col]] <- 0
}

# Identify any extra columns in test not present in train
extra_cols <- setdiff(names(test_dummy), names(train_dummy))

# Remove extra columns from test data
test_dummy <- test_dummy[, !(names(test_dummy) %in% extra_cols)]

# Reorder test columns to match training data exactly
test_dummy <- test_dummy[, names(train_dummy)]

# -------------------------------
# Separate Predictors and Target
# -------------------------------

# Separate predictor variables from target variable in training data
predictors_train <- train_dummy[, names(train_dummy) != "BAD"]

# Store target variable separately
target_train <- train_dummy$BAD

# -------------------------------
# Apply SMOTE
# -------------------------------

# Set seed for reproducibility
set.seed(2026)

# Apply SMOTE to oversample the minority class in the training set
smote_result <- SMOTE(
  X = predictors_train,
  target = target_train,
  K = 5,
  dup_size = 3
)

# Extract balanced training dataset
train_smote <- smote_result$data

# Rename last column as BAD
names(train_smote)[ncol(train_smote)] <- "BAD"

# Convert BAD back to factor
train_smote$BAD <- as.factor(train_smote$BAD)

# Check class counts after SMOTE
table(train_smote$BAD)

# Check class proportions after SMOTE
prop.table(table(train_smote$BAD))

# -------------------------------
# Logistic Regression
# -------------------------------

# Fit logistic regression model on SMOTE-balanced training data
log_model <- glm(BAD ~ ., data = train_smote, family = binomial)

# Display model summary
summary(log_model)

# Predict probabilities on test data
log_prob <- predict(log_model, test_dummy, type = "response")

# Convert predicted probabilities into class labels using 0.5 threshold
log_pred <- ifelse(log_prob > 0.5, 1, 0)
log_pred <- as.factor(log_pred)

# Evaluate logistic regression performance
confusionMatrix(log_pred, test_dummy$BAD, positive = "1")

# Compute ROC curve for logistic regression
roc_log <- roc(test_dummy$BAD, log_prob)

# Compute AUC for logistic regression
auc(roc_log)

# Plot ROC curve
plot(roc_log, col = "red", main = "ROC Curve - Logistic Regression")

# -------------------------------
# Decision Tree
# -------------------------------

# Fit classification tree
tree_model <- rpart(BAD ~ ., data = train_smote, method = "class",
                    control = rpart.control(cp = 0.01))

# Plot decision tree
rpart.plot(tree_model)

# Predict class labels on test data
tree_pred <- predict(tree_model, test_dummy, type = "class")

# Evaluate decision tree performance
confusionMatrix(tree_pred, test_dummy$BAD, positive = "1")

# Predict class probabilities for ROC/AUC
tree_prob <- predict(tree_model, test_dummy, type = "prob")[, 2]

# Compute ROC curve
roc_tree <- roc(test_dummy$BAD, tree_prob)

# Compute AUC
auc(roc_tree)

# Plot ROC curve
plot(roc_tree, col = "red", main = "ROC Curve - Decision Tree")

# -------------------------------
# Random Forest
# -------------------------------

# Fit random forest model
rf_model <- randomForest(BAD ~ ., data = train_smote, ntree = 500)

# Predict class labels on test data
rf_pred <- predict(rf_model, test_dummy)

# Evaluate random forest performance
confusionMatrix(rf_pred, test_dummy$BAD, positive = "1")

# Predict class probabilities
rf_prob <- predict(rf_model, test_dummy, type = "prob")[, 2]

# Compute ROC curve
roc_rf <- roc(test_dummy$BAD, rf_prob)

# Compute AUC
auc(roc_rf)

# Plot ROC curve
plot(roc_rf, col = "red", main = "ROC Curve - Random Forest")

# -------------------------------
# Naive Bayes
# -------------------------------

# Fit Naive Bayes model
nb_model <- naiveBayes(BAD ~ ., data = train_smote)

# Predict class labels on test data
nb_pred <- predict(nb_model, test_dummy)

# Evaluate Naive Bayes performance
confusionMatrix(nb_pred, test_dummy$BAD, positive = "1")

# Predict class probabilities
nb_prob <- predict(nb_model, test_dummy, type = "raw")[, 2]

# Compute ROC curve
roc_nb <- roc(test_dummy$BAD, nb_prob)

# Compute AUC
auc(roc_nb)

# Plot ROC curve
plot(roc_nb, col = "red", main = "ROC Curve - Naive Bayes")

# -------------------------------
# Compare AUC of Models
# -------------------------------

# Create a summary table to compare AUC values across models
model_auc <- data.frame(
  Model = c("Logistic Regression", "Decision Tree", "Random Forest", "Naive Bayes"),
  AUC = c(
    auc(roc_log),
    auc(roc_tree),
    auc(roc_rf),
    auc(roc_nb)
  )
)

# Display model comparison table
model_auc

# =========================================================
# LINEAR REGRESSION SECTION
# Predicting Property Value
# =========================================================

# Convert BAD back to numeric/factor-safe dataset is already imputed
# Use training and testing imputed data

# Fit linear regression model to predict VALUE
linear_model <- lm(VALUE ~ LOAN + MORTDUE + YOJ + DEROG + DELINQ + CLAGE +
                     NINQ + CLNO + DEBTINC + DEBTINC_MISS,
                   data = train_imputed)

# View model summary
summary(linear_model)

# Predict VALUE on test data
linear_pred <- predict(linear_model, newdata = test_imputed)

# Calculate regression errors
actual_value <- test_imputed$VALUE

MAE <- mean(abs(actual_value - linear_pred))
MSE <- mean((actual_value - linear_pred)^2)
RMSE <- sqrt(MSE)

# Show results
MAE
MSE
RMSE

# =========================================================
# CLUSTERING SECTION
# =========================================================

# -------------------------------
# Prepare Data for Clustering
# -------------------------------

# Remove target variable because clustering is unsupervised
cluster_data <- train_imputed[, names(train_imputed) != "BAD"]

# Convert categorical variables into dummy variables for clustering
cluster_dummy <- dummy_cols(
  cluster_data,
  select_columns = c("REASON", "JOB"),
  remove_first_dummy = TRUE,
  remove_selected_columns = TRUE
)

# Standardize variables so distance-based clustering is not dominated by scale
cluster_scaled <- scale(cluster_dummy)

# -------------------------------
# Elbow Method
# -------------------------------

# Set seed for reproducibility
set.seed(2026)

# Create vector to store within-cluster sum of squares for different k values
wss <- numeric(10)

# Compute WSS for k = 1 to 10
for (k in 1:10) {
  wss[k] <- kmeans(cluster_scaled, centers = k, nstart = 25)$tot.withinss
}

# Plot elbow method to help choose the number of clusters
plot(1:10, wss, type = "b",
     xlab = "Number of Clusters",
     ylab = "Within Cluster Sum of Squares",
     main = "Elbow Method for K-Means")

# -------------------------------
# K-Means Clustering
# -------------------------------

# Fit K-means clustering with 3 clusters
set.seed(2026)
kmeans_model <- kmeans(cluster_scaled, centers = 3, nstart = 25)

# Assign cluster labels to the training data
train_imputed$cluster <- as.factor(kmeans_model$cluster)

# Check cluster sizes
table(train_imputed$cluster)

# Compare clusters with BAD to understand default patterns within clusters
prop.table(table(train_imputed$cluster, train_imputed$BAD), 1)

# -------------------------------
# Silhouette Analysis
# -------------------------------

# Compute silhouette values to evaluate clustering quality
sil <- silhouette(kmeans_model$cluster, dist(cluster_scaled))

# Plot silhouette results
plot(sil, main = "Silhouette Plot for K-Means Clustering")

# Calculate average silhouette width
mean_silhouette <- mean(sil[, 3])

# Display average silhouette value
mean_silhouette


#############################
# CSDA 6010 – Project 3
# Consumer Behavior Analytics
#############################

# =========================
# 1. Load the dataset
# =========================

consumer.df <- read.csv("Consumer_Data.csv", stringsAsFactors = FALSE)

# View first few rows
head(consumer.df)

# Check dataset size
dim(consumer.df)

# Check column names
names(consumer.df)

# Check structure
str(consumer.df)

# Summary statistics
summary(consumer.df)

# =========================
# 2. Check missing values
# =========================

colSums(is.na(consumer.df))

# check duplicate rows
sum(duplicated(consumer.df))

# check unique customer IDs
length(unique(consumer.df$ID))

consumer.df[is.na(consumer.df$Income),]

round(colSums(is.na(consumer.df)) / nrow(consumer.df) * 100, 2)

# replace missing income with median
median_income <- median(consumer.df$Income, na.rm = TRUE)

consumer.df$Income[is.na(consumer.df$Income)] <- median_income

# checking again
colSums(is.na(consumer.df))

# check uniqueness of z_costContact and z_revenue -> constant value across all observations
unique(consumer.df$Z_CostContact)
unique(consumer.df$Z_Revenue)

# count zero in each column
zero_counts <- sapply(consumer.df[, sapply(consumer.df, is.numeric)],
                      function(x) sum(x == 0, na.rm = TRUE))

names(zero_counts[zero_counts>0])

# check uniqueness of z_costContact and z_revenue -> constant value across all observations
unique(consumer.df$Z_CostContact)
unique(consumer.df$Z_Revenue)

# January 1, 2014 is used as a fixed reference date
# so that Age and Customer_Tenure are calculated consistently
reference_date <- as.Date("2014-01-01")

# Create Age variable from Year_Birth
consumer.df$Age <- as.numeric(format(reference_date, "%Y")) - consumer.df$Year_Birth

# Convert customer joining date into date format
consumer.df$Dt_Customer <- as.Date(
  consumer.df$Dt_Customer,
  format = "%d-%m-%Y"
)

# Create Customer_Tenure variable in years
consumer.df$Customer_Tenure <- round(
  as.numeric(reference_date - consumer.df$Dt_Customer) / 365,
  1
)

# Remove unnecessary columns
consumer.df <- consumer.df %>%
  select(-c(
    ID,
    Year_Birth,
    Dt_Customer,
    Response,
    Z_CostContact,
    Z_Revenue
  ))

# Create Total_Spending variable
# by combining all product spending variables
consumer.df$Total_Spending <-
  consumer.df$MntFishProducts +
  consumer.df$MntFruits +
  consumer.df$MntGoldProds +
  consumer.df$MntMeatProducts +
  consumer.df$MntSweetProducts +
  consumer.df$MntWines

# Create Total_Purchase variable
# by combining all purchase channel variables
consumer.df$Total_Purchase <-
  consumer.df$NumCatalogPurchases +
  consumer.df$NumStorePurchases +
  consumer.df$NumWebPurchases

# Check customers with unrealistic age values
consumer.df[consumer.df$Age >= 100, ]

# Remove customers with age greater than 100
consumer.df <- consumer.df %>%
  filter(Age <= 100)

# Create Campaign_Response variable
# 1 = customer accepted at least one campaign
# 0 = customer did not accept any campaign
consumer.df$Campaign_Response <- ifelse(
  rowSums(
    consumer.df[, c(
      "AcceptedCmp1",
      "AcceptedCmp2",
      "AcceptedCmp3",
      "AcceptedCmp4",
      "AcceptedCmp5"
    )]
  ) > 0,
  1,
  0
)

# Convert Campaign_Response into factor variable
consumer.df$Campaign_Response <- as.factor(
  consumer.df$Campaign_Response
)

# Remove old campaign acceptance columns
consumer.df <- consumer.df %>%
  select(
    -AcceptedCmp1,
    -AcceptedCmp2,
    -AcceptedCmp3,
    -AcceptedCmp4,
    -AcceptedCmp5
  )

# View first few rows of cleaned dataset
head(consumer.df)

# =========================
#  Exploratory Data Analysis
# =========================
# -------------------------
# Distribution plots
# -------------------------

hist.df <- consumer.df %>%
  select(Income, Total_Spending, Recency, Age) %>%
  pivot_longer(cols = everything(),
               names_to = "Variable",
               values_to = "Value")

ggplot(hist.df, aes(x = Value)) +
  geom_histogram(fill = "white", color = "black", bins = 30) +
  facet_wrap(~Variable, scales = "free", ncol = 2) +
  labs(x = "", y = "Frequency") +
  theme_bw() +
  theme(strip.text = element_text(size = 12, face = "bold"))

# -------------------------
# Target distribution
# -------------------------

ggplot(consumer.df, aes(x = Campaign_Response)) +
  geom_bar() +
  labs(title = "Campaign Response Distribution",
       x = "Campaign_Response",
       y = "Count") +
  theme_minimal()

prop.table(table(consumer.df$Campaign_Response))

# -------------------------
# Numeric variable vs campaign acceptance
# -------------------------

#I took help from AI while using pivot_longer() here because I wanted to reshape the dataset from wide format to long
#format correctly for plotting and comparison across multiple variables. It helped me organize the selected columns 
#into a cleaner structure for visualization.
box.df <- consumer.df %>%
  select(Campaign_Response, Total_Spending, Income, Total_Purchase, Recency, Age) %>%
  pivot_longer(cols = c(Total_Spending, Income, Total_Purchase, Recency, Age),
               names_to = "Variable",
               values_to = "Value")

ggplot(box.df, aes(x = Campaign_Response, y = Value)) +
  geom_boxplot() +
  facet_wrap(~ Variable, scales = "free_y", ncol = 2) +
  labs(title = "Numeric Variables by Campaign Response",
       x = "Campaign Response",
       y = "Value") +
  theme_minimal()

# -------------------------
# Scatterplots for regression-related insight
# -------------------------

scatter.df <- consumer.df %>%
  select(Total_Spending, Income, Customer_Tenure) %>%
  pivot_longer(cols = c(Income, Customer_Tenure),
               names_to = "Variable",
               values_to = "X_Value")

ggplot(scatter.df, aes(x = X_Value, y = Total_Spending)) +
  geom_point(alpha = 0.5) +
  facet_wrap(~ Variable, scales = "free_x", ncol = 2) +
  labs(title = "Relationships with Total Spending",
       x = NULL,
       y = "Total Spending") +
  theme_minimal()

# -------------------------
# Categorical variables vs Campaign Response
# -------------------------

cat.df <- consumer.df %>%
  select(Education, Marital_Status, Campaign_Response) %>%
  pivot_longer(cols = c(Education, Marital_Status),
               names_to = "Variable",
               values_to = "Category")

ggplot(cat.df, aes(x = Category, fill = Campaign_Response)) +
  geom_bar(position = "fill") +
  scale_y_continuous(labels = percent) +
  facet_wrap(~ Variable, scales = "free_x") +
  labs(title = "Campaign Response Rate by Categorical Variables",
       x = "",
       y = "Percentage") +
  theme_minimal()

# -------------------------
# Summary tables by campaign acceptance
# -------------------------
aggregate(cbind(Income, Total_Spending, Total_Purchase, Recency, Customer_Tenure,Age) ~ Campaign_Response,
          data = consumer.df, mean)

aggregate(cbind(Income, Total_Spending, Total_Purchase, Recency, Customer_Tenure, Age) ~ Campaign_Response,
          data = consumer.df, median)

# -------------------------
# Correlation analysis
# -------------------------

# remove derived columns
#consumer.df <- consumer.df %>%
#  select(- c(Total_Spending, Total_Purchase))
# keep derived columns and remove original variables
consumer.df <- consumer.df %>%
  select(
    -c(
      MntWines,
      MntFruits,
      MntMeatProducts,
      MntFishProducts,
      MntSweetProducts,
      MntGoldProds,
      NumWebPurchases,
      NumCatalogPurchases,
      NumStorePurchases
    )
  )

# Check dataset dimensions
# Shows number of rows and columns
dim(consumer.df)

# Select only numeric variables
# Correlation can only be calculated for numeric data
numeric_vars <- consumer.df[, sapply(consumer.df, is.numeric)]

# Create correlation matrix
# complete.obs removes rows with missing values during calculation
cor_matrix <- cor(
  numeric_vars,
  use = "complete.obs"
)

# Round correlation values to 2 decimal places
round(cor_matrix, 2)

# Create correlation plot
corrplot(
  cor_matrix,
  method = "color",      # display correlations using colors
  type = "upper",        # show only upper triangle of matrix
  tl.cex = 0.8,          # variable label size
  number.cex = 0.7       # correlation number size
)
# =========================
# Supervised Learning
# =========================

# target as factor
consumer.df$Campaign_Response <- ifelse(consumer.df$Campaign_Response == "1", "Yes", "No")
consumer.df$Campaign_Response <- as.factor(consumer.df$Campaign_Response)

table(consumer.df$Campaign_Response)
prop.table(table(consumer.df$Campaign_Response))

# -------------------------
# Train-test split
# -------------------------
set.seed(2026)
train_index <- createDataPartition(consumer.df$Campaign_Response, p = 0.7, list = FALSE)

train.df <- consumer.df[train_index, ]
test.df  <- consumer.df[-train_index, ]

dim(train.df)
dim(test.df)

prop.table(table(train.df$Campaign_Response))
prop.table(table(test.df$Campaign_Response))

# -------------------------
# Create predictors and target
# -------------------------
train_x <- train.df %>%
  select(-Campaign_Response)

train_y <- ifelse(train.df$Campaign_Response == "Yes", 1, 0)

# -------------------------
# Dummy variables using training data only
# -------------------------
dummy_model_sv <- dummyVars(~ ., data = train_x)

train_x_dummy <- data.frame(predict(dummy_model_sv, newdata = train_x))

str(train_x_dummy)

# -------------------------
# Apply SMOTE on training data only
# -------------------------
set.seed(2026)
smote_result <- SMOTE(X = train_x_dummy, target = train_y, K = 5, dup_size = 2)

train_smote <- smote_result$data
names(train_smote)[ncol(train_smote)] <- "Campaign_Response"

train_smote$Campaign_Response <- ifelse(train_smote$Campaign_Response == 1, "Yes", "No")
train_smote$Campaign_Response <- as.factor(train_smote$Campaign_Response)

table(train_smote$Campaign_Response)
prop.table(table(train_smote$Campaign_Response))

# -------------------------
# Logistic Regression
# -------------------------
logit_model <- glm(Campaign_Response ~ ., data = train_smote, family = binomial())

summary(logit_model)

# -------------------------
# Prepare test data
# -------------------------
test_x <- test.df %>%
  select(-Campaign_Response)

test_x_dummy <- data.frame(predict(dummy_model_sv, newdata = test_x))

# add any missing columns in test data
missing_cols <- setdiff(names(train_x_dummy), names(test_x_dummy))

for (col in missing_cols) {
  test_x_dummy[[col]] <- 0
}

# keep same column order as training data
test_x_dummy <- test_x_dummy[, names(train_x_dummy)]

# -------------------------
# Prediction
# -------------------------
logit_prob <- predict(logit_model, newdata = test_x_dummy, type = "response")

logit_pred <- ifelse(logit_prob > 0.5, "Yes", "No")
logit_pred <- as.factor(logit_pred)
logit_pred <- factor(logit_pred, levels = levels(test.df$Campaign_Response))

# -------------------------
# Evaluation
# -------------------------
confusionMatrix(logit_pred, test.df$Campaign_Response, positive = "Yes")

roc_obj <- roc(test.df$Campaign_Response, logit_prob, levels = c("No", "Yes"))
auc(roc_obj)
plot(roc_obj, main = "Logistic Regression ROC Curve")

# -------------------------
# Naive Bayes
# -------------------------
nb_model <- naiveBayes(Campaign_Response ~ ., data = train_smote)

nb_pred <- predict(nb_model, newdata = test_x_dummy, type = "class")
nb_prob <- predict(nb_model, newdata = test_x_dummy, type = "raw")[, "Yes"]

confusionMatrix(nb_pred, test.df$Campaign_Response, positive = "Yes")

nb_roc <- roc(test.df$Campaign_Response, nb_prob, levels = c("No", "Yes"))
auc(nb_roc)
plot(nb_roc, main = "Naive Bayes ROC Curve")

# -------------------------
# Decision Tree
# -------------------------
tree_model <- rpart(Campaign_Response ~ ., data = train_smote, method = "class")

rpart.plot(tree_model)

tree_prob <- predict(tree_model, newdata = test_x_dummy, type = "prob")[, "Yes"]
tree_pred <- predict(tree_model, newdata = test_x_dummy, type = "class")

confusionMatrix(tree_pred, test.df$Campaign_Response, positive = "Yes")

tree_roc <- roc(test.df$Campaign_Response, tree_prob, levels = c("No", "Yes"))
auc(tree_roc)
plot(tree_roc, main = "Decision Tree ROC Curve")

# -------------------------
# Random Forest
# -------------------------

# Build Random Forest classification model
# ntree = 500 means the model will create 500 decision trees
rf_model <- randomForest(
  Campaign_Response ~ .,
  data = train_smote,
  ntree = 500
)

# Print model summary
print(rf_model)

# Predict campaign response class for test data
rf_pred <- predict(
  rf_model,
  newdata = test_x_dummy,
  type = "class"
)

# Predict probability of "Yes" campaign response
rf_prob <- predict(
  rf_model,
  newdata = test_x_dummy,
  type = "prob"
)[, "Yes"]

# Evaluate Random Forest using confusion matrix
confusionMatrix(
  rf_pred,
  test.df$Campaign_Response,
  positive = "Yes"
)

# Create ROC curve object for Random Forest
rf_roc <- roc(
  test.df$Campaign_Response,
  rf_prob,
  levels = c("No", "Yes")
)

# Calculate AUC for Random Forest
auc(rf_roc)

# Plot ROC curve for Random Forest
plot(
  rf_roc,
  main = "Random Forest ROC Curve"
)

# Create model comparison table
# This table compares all classification models using Accuracy,
# Sensitivity, Specificity, and AUC
model_results <- data.frame(
  Model = c(
    "Logistic Regression",
    "Decision Tree",
    "Random Forest",
    "Naive Bayes"
  ),
  
  Accuracy = c(
    as.numeric(confusionMatrix(logit_pred, test.df$Campaign_Response, positive = "Yes")$overall["Accuracy"]),
    as.numeric(confusionMatrix(tree_pred, test.df$Campaign_Response, positive = "Yes")$overall["Accuracy"]),
    as.numeric(confusionMatrix(rf_pred, test.df$Campaign_Response, positive = "Yes")$overall["Accuracy"]),
    as.numeric(confusionMatrix(nb_pred, test.df$Campaign_Response, positive = "Yes")$overall["Accuracy"])
  ),
  
  Sensitivity = c(
    as.numeric(confusionMatrix(logit_pred, test.df$Campaign_Response, positive = "Yes")$byClass["Sensitivity"]),
    as.numeric(confusionMatrix(tree_pred, test.df$Campaign_Response, positive = "Yes")$byClass["Sensitivity"]),
    as.numeric(confusionMatrix(rf_pred, test.df$Campaign_Response, positive = "Yes")$byClass["Sensitivity"]),
    as.numeric(confusionMatrix(nb_pred, test.df$Campaign_Response, positive = "Yes")$byClass["Sensitivity"])
  ),
  
  Specificity = c(
    as.numeric(confusionMatrix(logit_pred, test.df$Campaign_Response, positive = "Yes")$byClass["Specificity"]),
    as.numeric(confusionMatrix(tree_pred, test.df$Campaign_Response, positive = "Yes")$byClass["Specificity"]),
    as.numeric(confusionMatrix(rf_pred, test.df$Campaign_Response, positive = "Yes")$byClass["Specificity"]),
    as.numeric(confusionMatrix(nb_pred, test.df$Campaign_Response, positive = "Yes")$byClass["Specificity"])
  ),
  
  AUC = c(
    as.numeric(auc(roc_obj)),
    as.numeric(auc(tree_roc)),
    as.numeric(auc(rf_roc)),
    as.numeric(auc(nb_roc))
  )
)

# Round metric values to 4 decimal places
model_results[, -1] <- round(model_results[, -1], 4)

# Display final model comparison table
model_results

# =========================
# Regression Model
# =========================

# split data
set.seed(2026)
train_index_reg <- createDataPartition(consumer.df$Total_Spending, p = 0.7, list = FALSE)

train_reg <- consumer.df[train_index_reg, ]
test_reg  <- consumer.df[-train_index_reg, ]

# remove target and the spending variables used to create it
# remove target variable only
train_x_reg <- train_reg %>%
  select(-Total_Spending)

test_x_reg <- test_reg %>%
  select(-Total_Spending)

# create dummy variables
dummy_model_reg <- dummyVars(~ ., data = train_x_reg)

train_x_reg_dummy <- data.frame(predict(dummy_model_reg, newdata = train_x_reg))
test_x_reg_dummy  <- data.frame(predict(dummy_model_reg, newdata = test_x_reg))

# add missing columns in test if needed
missing_cols_reg <- setdiff(names(train_x_reg_dummy), names(test_x_reg_dummy))

for (col in missing_cols_reg) {
  test_x_reg_dummy[[col]] <- 0
}

# keep same column order
test_x_reg_dummy <- test_x_reg_dummy[, names(train_x_reg_dummy)]

# add target back
train_reg_final <- cbind(train_x_reg_dummy, Total_Spending = train_reg$Total_Spending)
test_reg_final  <- cbind(test_x_reg_dummy, Total_Spending = test_reg$Total_Spending)

# linear regression model
lm_model <- lm(Total_Spending ~ ., data = train_reg_final)

summary(lm_model)

# prediction
lm_pred <- predict(lm_model, newdata = test_reg_final)

# evaluation
MAE <- mean(abs(test_reg_final$Total_Spending - lm_pred))
RMSE <- sqrt(mean((test_reg_final$Total_Spending - lm_pred)^2))
R2 <- cor(test_reg_final$Total_Spending, lm_pred)^2

MAE
RMSE
R2

# =========================
# Random Forest Regression
# =========================

# build random forest regression model
set.seed(2026)
rf_reg_model <- randomForest(
  Total_Spending ~ .,
  data = train_reg_final,
  ntree = 500
)

print(rf_reg_model)

# prediction
rf_reg_pred <- predict(rf_reg_model, newdata = test_reg_final)

# evaluation
rf_reg_MAE <- mean(abs(test_reg_final$Total_Spending - rf_reg_pred))
rf_reg_RMSE <- sqrt(mean((test_reg_final$Total_Spending - rf_reg_pred)^2))
rf_reg_R2 <- cor(test_reg_final$Total_Spending, rf_reg_pred)^2

rf_reg_MAE
rf_reg_RMSE
rf_reg_R2

# =========================
# Regression Results Table
# =========================
# I took help from ChatGPT to organize the regression results table.
regression_results <- data.frame(
  Model = c("Linear Regression", "Random Forest Regression"),
  MAE = c(MAE, rf_reg_MAE),
  RMSE = c(RMSE, rf_reg_RMSE),
  R2 = c(R2, rf_reg_R2)
)

regression_results[, -1] <- round(regression_results[, -1], 4)

regression_results

# =========================
# Unsupervised Learning
# =========================

unsupervised.df <- consumer.df %>%
  select(-Campaign_Response)

# convert categorical variables into dummy variables
dummy_var <- dummyVars(~ ., data = unsupervised.df)
unsupervised_dummy <- data.frame(predict(dummy_var, newdata = unsupervised.df))

# check missing values
colSums(is.na(unsupervised_dummy))
sum(is.na(unsupervised_dummy))

# scale variables
unsupervised_scaled <- scale(unsupervised_dummy)

# -------------------------
# Elbow Method
# -------------------------
set.seed(2026)

wss <- numeric(10)

for (k in 1:10) {
  km <- kmeans(unsupervised_scaled, centers = k, nstart = 25)
  wss[k] <- km$tot.withinss
}

plot(1:10, wss, type = "b",
     xlab = "Number of Clusters",
     ylab = "Within-cluster sum of squares",
     main = "Elbow Method for K-means")

for (k in 2:6) {
  km <- kmeans(unsupervised_scaled, centers = k, nstart = 25)
  cat("k =", k, "WSS =", km$tot.withinss, "\n")
}

# -------------------------
# Silhouette Method
# -------------------------
k_values <- 2:5
sil_width <- numeric(length(k_values))

set.seed(2026)

for (i in seq_along(k_values)) {
  k <- k_values[i]
  km <- kmeans(unsupervised_scaled, centers = k, nstart = 25)
  ss <- silhouette(km$cluster, dist(unsupervised_scaled))
  sil_width[i] <- mean(ss[, 3])
}

plot(k_values, sil_width, type = "b",
     xlab = "Number of Clusters",
     ylab = "Average Silhouette Width",
     main = "Silhouette Method for K-means")

# -------------------------
# Final K-means Model with 2 Clusters
# -------------------------
set.seed(2026)

kmeans_model_2 <- kmeans(unsupervised_scaled, centers = 2, nstart = 25)

consumer.df$Cluster2 <- as.factor(kmeans_model_2$cluster)

table(consumer.df$Cluster2)

# -------------------------
# Cluster Centroid Profile Plot
# -------------------------
cluster_plot_2 <- as.data.frame(unsupervised_scaled)
cluster_plot_2$Cluster <- consumer.df$Cluster2

centroids_2 <- aggregate(. ~ Cluster, data = cluster_plot_2, mean)
centroids2_t <- t(centroids_2[, -1])

par(mar = c(14, 5, 4, 2))

matplot(
  centroids2_t,
  type = "l",
  lty = 1,
  lwd = 2,
  col = c("black", "red"),
  axes = FALSE,      # remove all automatic axes
  xlab = "",
  ylab = "Scaled Value",
  main = "Cluster Centroid Profiles (2 Clusters)"
)

# Add y-axis
axis(2)

# Add custom x-axis
axis(
  side = 1,
  at = 1:nrow(centroids2_t),
  labels = abbreviate(rownames(centroids2_t), minlength = 8),
  las = 2,
  cex.axis = 2
)

# Add legend
legend(
  "topright",
  legend = c("Cluster 1", "Cluster 2"),
  col = c("black", "red"),
  lty = 1,
  lwd = 2
)

