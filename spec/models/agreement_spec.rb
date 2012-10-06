require 'spec_helper'

describe Agreement do
  it { should validate_presence_of :user_name }
  it { should validate_presence_of :repo_name }
  it { should validate_presence_of :text }
  it { should belong_to :user }
  it { should have_many :signatures }

  it "has many signing_users through signatures" do
    user = create(:user)
    user2 = create(:user)
    agreement = create(:agreement)
    create(:signature, user: user, agreement: agreement)
    create(:signature, user: user2, agreement: agreement)

    expect(agreement.signing_users).to eq([user, user2])
  end

  it { should allow_mass_assignment_of(:repo_name) }
  it { should allow_mass_assignment_of(:text) }
  it { should_not allow_mass_assignment_of(:user_name) }
  it { should_not allow_mass_assignment_of(:user_id) }

  it "sets user_name" do
    user = build(:user, nickname: "jimbo")
    agreement = build(:agreement, user: user)

    agreement.save

    expect(agreement.user_name).to eq("jimbo")
    expect(agreement.reload.user_name).to eq("jimbo")
  end

  it "create a github repo hook" do
    agreement = build(:agreement)

    hook_inputs = {
      'name' => 'web',
      'config' => {
        'url' => "#{HOST}/repo_hook"
      }
    }

    github_repos = double(create_hook: { 'id' => 12345 })
    GithubRepos.stub(new: github_repos)

    github_repos.should_receive(:create_hook).with(agreement.user_name, agreement.repo_name, hook_inputs)
    GithubRepos.should_receive(:new).with(agreement.user)

    agreement.create_github_repo_hook

    expect(agreement.github_repo_hook_id).to eq(12345)
  end

  it "can delete its github repo hook" do
    agreement = build(:agreement, github_repo_hook_id: 7890)

    hook_inputs = {
      'name' => 'web',
      'config' => {
        'url' => "#{HOST}/repo_hook"
      }
    }

    github_repos = double(delete_hook: nil) # on not-found, raises Github::Error::NotFound
    GithubRepos.stub(new: github_repos)

    github_repos.should_receive(:delete_hook).with(agreement.user_name, agreement.repo_name, agreement.github_repo_hook_id)
    GithubRepos.should_receive(:new).with(agreement.user)

    agreement.delete_github_repo_hook
    expect(agreement.github_repo_hook_id).to be_nil
  end
end