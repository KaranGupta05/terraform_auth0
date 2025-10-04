# Environment Protection Rules Setup

This guide helps you configure approval gates for production deployments to ensure safe and controlled infrastructure changes.

## 🔒 Why Environment Protection is Important

- **Prevents accidental production deployments**
- **Requires manual review of Terraform plans before applying**
- **Adds audit trail for production changes**
- **Allows for deployment rollback planning**

## 📋 Step-by-Step Setup

### 1. Navigate to Environment Settings
Go to: [Repository Environment Settings](https://github.com/KaranGupta05/teraform_auth0/settings/environments)

### 2. Configure Production Environment

Click on the **"production"** environment and add these protection rules:

#### Required Reviewers
- ✅ **Add 1-2 team members** who can approve production deployments
- ✅ **Require review from CODEOWNERS** (if you have a CODEOWNERS file)
- ⚠️ **Never approve your own deployments** (check this option for security)

#### Wait Timer (Optional but Recommended)
- ✅ **15 minutes** - Provides a cooling-off period to catch any last-minute issues
- This allows time to:
  - Double-check the Terraform plan
  - Coordinate with team members
  - Prepare rollback procedures if needed

#### Deployment Branch Policy
- ✅ **Restrict deployments to selected branches**
- ✅ **Add branches**: `main` and `master`
- This ensures only stable code reaches production

### 3. Configure Staging Environment (Recommended)

Click on the **"staging"** environment:

- ✅ **1 required reviewer** (for validation testing)
- ✅ **5-minute wait timer** (shorter than production)
- ✅ **Allow deployment from**: `release/*`, `hotfix/*`, `main`, `master`

### 4. Development Environment

The **"development"** environment should remain **without restrictions** for fast iteration.

## 🚀 How Approvals Work in the Workflow

### Before Approval
1. **Terraform Plan** runs automatically and shows what changes will be made
2. **Plan details** are posted as PR comments for review
3. **Deployment job** waits for approval in GitHub Actions

### During Approval
1. **Designated reviewers** get notified of pending deployment
2. **Reviewers can examine**:
   - Terraform plan output
   - Files being changed
   - Commit history
3. **Reviewers approve or reject** the deployment

### After Approval
1. **Wait timer** starts (if configured)
2. **Terraform Apply** runs automatically
3. **Deployment summary** is generated
4. **Release tag** is created for production deployments

## 📧 Approval Notifications

Team members will receive notifications via:
- **GitHub notifications** (in-app and email)
- **Slack** (if GitHub Slack app is configured)
- **Teams** (if GitHub Teams app is configured)

## 🔄 Emergency Bypasses

### Admin Override
- Repository admins can bypass protection rules if needed
- Use only for emergency hotfixes
- Document the reason in deployment notes

### Workflow Dispatch
- Use manual workflow triggers for emergency deployments
- Still requires environment approvals
- Useful for off-hours deployments

## 📊 Monitoring and Auditing

All deployments are tracked in:
- **GitHub Actions logs** - Full deployment history
- **Environment deployment history** - Per-environment tracking  
- **Release tags** - Production deployment markers
- **Git commit history** - Change tracking

## 🚨 Best Practices

### For Reviewers
- ✅ **Always review the Terraform plan** before approving
- ✅ **Check for destructive changes** (resource deletions)
- ✅ **Verify the source branch** matches expectations
- ✅ **Coordinate with team** for major changes

### For Developers
- ✅ **Test thoroughly** in development and staging first
- ✅ **Write clear commit messages** explaining changes
- ✅ **Update documentation** for infrastructure changes
- ✅ **Plan rollback strategy** before production deployment

## 🔧 Troubleshooting

### Approval Not Triggering
- Check if reviewers are correctly added to environment
- Verify GitHub notifications are enabled
- Ensure branch protection rules allow the deployment

### Deployment Stuck in "Waiting"
- Check if all required approvals are received
- Verify wait timer hasn't been exceeded
- Look for environment protection rule conflicts

### Emergency Deployment Needed
1. Use `workflow_dispatch` with force_deploy option
2. Still requires approval (security feature)
3. Document emergency reason in deployment notes

---

## 🎯 Quick Setup Checklist

- [ ] Production environment: 2 reviewers + 15min wait + main branch only
- [ ] Staging environment: 1 reviewer + 5min wait + release branches
- [ ] Development environment: No restrictions
- [ ] Test deployment flow with a small change
- [ ] Verify notifications reach the right people
- [ ] Document emergency procedures for your team

**Need help?** Check the [GitHub Environments Documentation](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment) for more details.