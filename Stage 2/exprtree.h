#include<stdio.h>
#include<stdlib.h>

struct tree_node{
	int val;
	char op;
	struct tree_node *left,*right;
};

struct tree_node* mkLeafNode(int v){
	struct tree_node *ptr = malloc(sizeof(struct tree_node));
	ptr->left = NULL;
	ptr->right= NULL;
	ptr->val = v;
	ptr->op = 'l';
	return ptr;
}

struct tree_node* mkOpNode(char opr, struct tree_node *l, struct tree_node *r){
	struct tree_node *ptr = malloc(sizeof(struct tree_node));
	ptr->left = l;
	ptr->right= r;
	ptr->op = opr;
	return ptr;
}

int evaluate(struct tree_node *node){
	switch(node->op){
		case '+': return evaluate(node->left) + evaluate(node->right);break;
		case '-': return evaluate(node->left) - evaluate(node->right);break;
		case '*': return evaluate(node->left) * evaluate(node->right);break;
		case '/': return evaluate(node->left) / evaluate(node->right);break;
		case '%': return evaluate(node->left) % evaluate(node->right);break;
		default : return node->val;break;
	}
}
int postorder(struct tree_node *root){
    if(root!=NULL){
		postorder(root->left);
		postorder(root->right);
		if(root->op !='l')
			printf("%c ",root->op);
		else
			printf("%d ",root->val);
   }
   return 0;
}

