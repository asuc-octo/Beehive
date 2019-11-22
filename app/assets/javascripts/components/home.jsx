class Home extends React.Component {
  	render() {
  		let explore_button;
  		if (!this.props.present){
  			explore_button = <LandingButton path={this.props.login_path} label="EXPLORE"/>
  		} else if (this.props.present && this.props.undergrad) {
			explore_button = <LandingButton path={this.props.jobs_path} label="EXPLORE"/>
		} else {
			explore_button = <LandingButton path={this.props.dashboard_path} label="EXPLORE"/>
		}
    	return 	<div id="home-container">
				  <div class="main-top-bg-container">
				    <div class="main-top-bg"></div>
				  </div>
				  <div class="main-top">
				    <div class="main-title">
				      <div class="text-info-large">
				        <span>
				          Research made simple
				        </span>
				      </div>
				    </div>
				    <div class="main-top-info">
				      <div class="text-info-small">
				        Explore
				        <span>
				        	{" " + this.props.job_count + " "} 
				        </span>
				        exciting projects and counting.
				        Starting research has never been easier!
				      </div>
				    </div>
				    <span class="main-icons-container">
				      <div class="main-icons"></div>
				    </span>
				  </div>
				  <div class="main-btn-container clearfix">
				    	{explore_button}
				  		<LandingButton path={this.props.team_path} label="ABOUT US" />
				  </div>
				  <div class="row main-bottom">
				  	<LandingCard title="BROWSE" details="We've made it easy for you to find your perfect project."/>
				    <LandingCard title="EASY APPLYING" details="No need to fill out endless forms. Write what's relevant, and we'll take care of the rest."/>
				    <LandingCard title="SMARTMATCH" details="Can't find a project you like? We'll let you know when a new project matches your interests."/>
				  </div>
				</div>

  }
}
class LandingButton extends React.Component {
	render(){
		return <a href={this.props.path} class="btn btn-cal btn-landing">{this.props.label}</a>
	}
}
class LandingCard extends React.Component {
	render(){
		return <div class="col-md-4 col-landing-card">
			      <div class="smartmatch landing-card">
			        <div class="title">
			          {this.props.title}
			        </div>
			        <div class="details">
			          {this.props.details}
			        </div>
			      </div>
			    </div>
	}
}