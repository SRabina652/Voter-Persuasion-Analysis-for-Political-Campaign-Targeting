# Load Packages
library(class)
library(dplyr)
library(caret)
library(rpart)
library(rpart.plot)
library(pROC)
library(fastDummies)

#2 Read data

VoterPersuasion <- read.csv("C:/Users/shahi/OneDrive/Desktop/webster/Analytics Practicum Analytics Pract/project1/week 1/VoterPersuasion.csv")

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
ncol(num_col_more_than_4_df)
nrow(num_col_more_than_4_df)

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
"# Interpretation: Most voters did not change position → class imbalance."

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

plot(pca_train, type = "l", main = "Scree Plot")

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

#Create a voter targeting list based on predicted persuasion probability

targeting_list <- test_pred %>%
  mutate(
    predicted_prob = pred_prob,
    actual_moved = test_outcome
  ) %>%
  arrange(desc(predicted_prob))

# View top 20 voters most likely to be persuaded
head(targeting_list, 20)

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

